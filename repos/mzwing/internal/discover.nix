# Wire package arguments from generated sources, `pkgs` and sibling packages; callPackage supplies the rest.
{lib}: let
  # Package directories; one whose source.ts has no generated source.nix yet joins once the update workflow generates it.
  packageDirs = dir: let
    entries = builtins.readDir dir;
  in
    builtins.filter (
      name: let
        path = dir + "/${name}";
      in
        entries.${name}
        == "directory"
        && builtins.pathExists (path + "/default.nix")
        && (builtins.pathExists (path + "/source.ts") -> builtins.pathExists (path + "/source.nix"))
    ) (builtins.attrNames entries);

  packages = {
    pkgs,
    dir,
  }: let
    # Arguments this repository supplies; anything else falls through to callPackage.
    autoArgsFor = name: let
      file = dir + "/${name}/default.nix";
      argFor = arg:
        if arg == "source"
        then [
          {
            name = arg;
            value = pkgs.callPackage (dir + "/${name}/source.nix") {};
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
        else [];
    in
      builtins.listToAttrs (
        builtins.concatMap argFor (builtins.attrNames (builtins.functionArgs (import file)))
      );

    result = builtins.listToAttrs (map (name: {
      inherit name;
      value = pkgs.callPackage (dir + "/${name}/default.nix") (autoArgsFor name);
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
