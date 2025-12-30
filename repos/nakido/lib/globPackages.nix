lib:
let
  globPackages =
    path:
    let
      entries = builtins.readDir path;
      hasDefaultNix = builtins.pathExists (path + "/default.nix") && !(builtins.pathExists (path + "/disabled"));
      subdirs = lib.attrsets.filterAttrs (name: type: type == "directory") entries;

      subdirResults = lib.lists.concatMap (name: globPackages (path + "/${name}")) (
        lib.attrsets.attrNames subdirs
      );
    in
    (if hasDefaultNix then [ path ] else [ ]) ++ subdirResults;
in
globPackages