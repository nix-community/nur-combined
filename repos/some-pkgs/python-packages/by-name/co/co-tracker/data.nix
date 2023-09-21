{ lib, pkgs }:

let
  inherit (lib) types;
  data =
    lib.evalModules
      {
        modules = [
          {
            options.weights = lib.mkOption {
              type = types.attrsOf (types.remoteFile { inherit pkgs; });
            };
          }
          (import ./data_config.nix)
        ];
      };
in
data
