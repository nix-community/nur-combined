{ lib, pkgs }:

let
  inherit (lib) types mkOption;
  inherit (types) attrsOf;
  inherit (pkgs.some-util) remoteFile;

  data =
    lib.evalModules
      {
        modules = [
          {
            options.weights = lib.mkOption {
              type = types.attrsOf remoteFile;
            };
          }
          (import ./data_config.nix)
        ];
      };
in
data
