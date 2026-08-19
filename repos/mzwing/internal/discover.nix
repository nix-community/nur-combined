# Inject package arguments from sources, `pkgs`, local packages, injected values, then nixpkgs; `extraArgs` overrides per package.
{lib ? null}: let
  # Repository-relative default sources.
  defaultSources = pkgs: pkgs.callPackage ../_sources/generated.nix {};

  # Lazy repo-wide gomod2nix builder injection.
  defaultInject = pkgs: let
    overlaid = pkgs.extend (import ((import ./gomod2nix.nix) + "/overlay.nix"));
  in {
    buildGoApplication = overlaid.buildGoApplication;
  };

  # Package directories.
  packageDirs = dir: let
    entries = builtins.readDir dir;
  in
    builtins.filter (
      name:
        entries.${name}
        == "directory"
        && builtins.pathExists (dir + "/${name}/default.nix")
    ) (builtins.attrNames entries);

  packages = {
    pkgs,
    dir,
    sources ? defaultSources pkgs,
    inject ? defaultInject pkgs,
    extraArgs ? {},
  }: let
    autoArgsFor = name: let
      fargs = builtins.functionArgs (import (dir + "/${name}/default.nix"));
      shouldInject = arg:
        (arg == "source" && builtins.hasAttr name sources)
        || arg == "pkgs"
        || builtins.hasAttr arg result
        || builtins.hasAttr arg sources
        || builtins.hasAttr arg inject;
      valueFor = arg:
        if arg == "source" && builtins.hasAttr name sources
        then builtins.getAttr name sources
        else if arg == "pkgs"
        then pkgs
        else if builtins.hasAttr arg result
        then builtins.getAttr arg result
        else if builtins.hasAttr arg sources
        then builtins.getAttr arg sources
        else builtins.getAttr arg inject;
    in
      builtins.listToAttrs (map (arg: {
        name = arg;
        value = valueFor arg;
      }) (builtins.filter shouldInject (builtins.attrNames fargs)));

    result = builtins.listToAttrs (map (name: {
      inherit name;
      value = pkgs.callPackage (dir + "/${name}/default.nix") (
        autoArgsFor name
        // (
          if builtins.hasAttr name extraArgs
          then builtins.getAttr name extraArgs
          else {}
        )
      );
    }) (packageDirs dir));
  in
    result;
in {
  outputs = {
    dir,
    args,
  }: let
    discover = directory: let
      entries = builtins.readDir directory;
    in
      lib.concatMap (
        name: let
          entryType = entries.${name};
          path = directory + "/${name}";
        in
          if entryType == "directory"
          then discover path
          else if entryType == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name
          then [path]
          else []
      ) (builtins.attrNames entries);

    merge = accumulated: discovered: let
      duplicateNames = lib.intersectLists (builtins.attrNames accumulated) (builtins.attrNames discovered);
    in
      if duplicateNames != []
      then throw "duplicate discovered output names: ${lib.concatStringsSep ", " duplicateNames}"
      else accumulated // discovered;
  in
    lib.foldl' merge {} (map (path: import path args) (discover dir));

  subdirs = dir: let
    entries = builtins.readDir dir;
  in
    builtins.listToAttrs (map (name: {
      inherit name;
      value = dir + "/${name}";
    }) (builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries)));

  inherit packages;

  package = {
    pkgs,
    name,
    sources ? defaultSources pkgs,
  }:
    builtins.getAttr name (packages {
      inherit pkgs sources;
      dir = ../pkgs;
    });
}
