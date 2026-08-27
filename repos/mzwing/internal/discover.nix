# Wire package arguments from sources, `pkgs` and sibling packages; callPackage supplies the rest.
{lib}: let
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
    sources,
    extraArgs ? {},
  }: let
    # Arguments this repository supplies; anything else falls through to callPackage.
    autoArgsFor = name: let
      file = dir + "/${name}/default.nix";
      argFor = arg:
        if arg == "source" && sources ? ${name}
        then [
          {
            name = arg;
            value = sources.${name};
          }
        ]
        else if arg == "pkgs"
        then [
          {
            name = arg;
            value = pkgs;
          }
        ]
        else if result ? ${arg}
        then [
          {
            name = arg;
            value = result.${arg};
          }
        ]
        else if sources ? ${arg}
        then [
          {
            name = arg;
            value = sources.${arg};
          }
        ]
        else [];
    in
      builtins.listToAttrs (
        builtins.concatMap argFor (builtins.attrNames (builtins.functionArgs (import file)))
      );

    result = builtins.listToAttrs (map (name: {
      inherit name;
      value = pkgs.callPackage (dir + "/${name}/default.nix") (
        autoArgsFor name // extraArgs.${name} or {}
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

  inherit packages;
}
