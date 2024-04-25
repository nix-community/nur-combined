{ pkgs, callPackage }:
let
  inherit (pkgs) lib;

  mergeAttrsList = let
    mergeAttrsList' = lib.foldl lib.mergeAttrs { };
  in lib.mergeAttrsList or mergeAttrsList';

  importSub = prefix: attrs: lib.flip lib.mapAttrs attrs (
    name: args: let
      path = lib.path.append prefix name;
    in callPackage path args
  );

  applications = importSub ./applications {
    ferdium = { };
    paru = { };
  };

  servers = importSub ./servers {
    cryptpad = { };
  };

in mergeAttrsList [
  applications
  servers
]
