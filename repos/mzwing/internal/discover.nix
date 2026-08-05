# Directory auto-discovery helpers for this repository.
#
# Import as:
#
#   discover = import ./internal/discover.nix { inherit (pkgs) lib; };
#
# Exported functions:
#
#   outputs { dir, args }
#     Recursively find every *.nix file under `dir` (excluding files named
#     default.nix), call each with `args`, and merge the resulting attribute
#     sets. Throws on duplicate top-level attribute names. Used by scripts/.
#
#   subdirs dir
#     Return { <name> = dir + "/<name>"; } for every first-level subdirectory
#     of `dir`. Used by nixos-modules/, darwin-modules/ and home-modules/ so
#     that adding a module directory requires no registration.
#
#   packages { pkgs, dir, sources ? <_sources>, extraArgs ? {} }
#     Automatically wire up packages: for every first-level subdirectory of
#     `dir` containing a default.nix, build it with `pkgs.callPackage` and
#     auto-inject arguments based on the function's formal parameters
#     (builtins.functionArgs), using the following precedence:
#       1. an argument named `source` whose package name exists in `sources`
#          receives sources.<package name>;
#       2. an argument matching another package in this set receives that
#          package (lazy recursion, e.g. typenix-vscode -> typenix);
#       3. an argument matching a key of `sources` receives that source
#          (e.g. typenix's tree-sitter-nix);
#       4. everything else is left for callPackage to resolve from nixpkgs
#          (e.g. sing-box).
#     `extraArgs.<name>` is an explicit exception table that overrides
#     auto-injection (e.g. typenix-vscode's `source` is sources.typenix).
#     `sources` defaults to the repository's ../_sources/generated.nix.
#
#     NOTE: rule 2 takes precedence over nixpkgs resolution, so adding a
#     local package whose name collides with a nixpkgs argument used by
#     another package (e.g. a local `sing-box`) shadows it; use `extraArgs`
#     to wire such cases explicitly.
#
#   package { pkgs, name, sources ? <_sources> }
#     Build a single package from ../pkgs/<name> with the same auto-injection
#     rules (lazy: only the requested package is built). Used by modules/ to
#     construct their default packages without duplicating the wiring.
{lib}: let
  # Anchored at this file's location (internal/) so callers don't need to
  # thread the repository root through.
  defaultSources = pkgs: pkgs.callPackage ../_sources/generated.nix {};

  # Names of first-level subdirectories of dir that contain a default.nix.
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
    extraArgs ? {},
  }: let
    autoArgsFor = name: let
      fargs = builtins.functionArgs (import (dir + "/${name}/default.nix"));
      shouldInject = arg:
        (arg == "source" && builtins.hasAttr name sources)
        || builtins.hasAttr arg result
        || builtins.hasAttr arg sources;
      valueFor = arg:
        if arg == "source" && builtins.hasAttr name sources
        then builtins.getAttr name sources
        else if builtins.hasAttr arg result
        then builtins.getAttr arg result
        else builtins.getAttr arg sources;
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
