{ pkgs, lib, callPackage, ... }:
let
  mergeAttrsList = let
    mergeAttrsList' = lib.foldl lib.mergeAttrs { };
  in lib.mergeAttrsList or mergeAttrsList';

  importSub = prefix: attrs: lib.flip lib.mapAttrs attrs (
    name: {
      _file ? null,
      _path ? if _file != null
        then lib.path.append prefix "${name}/${_file}"
        else lib.path.append prefix name,
      _attr ? null,
      _common ? null,
      ...
    }@args: let
      args' =
        builtins.removeAttrs args [ "_file" "_path" "_attr" "_common" ]
        // lib.optionalAttrs (_common != null) {
          _common = callPackage ./common/${_common}.nix { };
        };
      package = callPackage _path args';
    in if _attr != null then package.${_attr} else package
  );

  applications = importSub ./applications {
    aura = { };
    enquirer = { };
    ferdium = { };
    go-mod-upgrade = { };
    imhex = { };
    lddtree = { };
    paru = { };
    ots-cli = {
      _common = "ots";
    };
    streampager = { };
    tumelune = { };
  };

  development = importSub ./development {
  };

  servers = importSub ./servers {
    cryptpad = { };
    freenginx = {
      modules = with pkgs.nginxModules; [ moreheaders ];
    };
    ots = {
      _common = "ots";
    };
    piped-proxy = { };
  };

in mergeAttrsList [
  applications
  development
  servers
]
