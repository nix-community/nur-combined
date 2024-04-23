{ config, lib, ... }:

let
  inherit (lib) mkOption types;
  inherit (config.systemd) forbiddenPaths;
in

{
  options = {
    systemd.forbiddenPaths = mkOption {
      default = [];
      type = types.listOf types.path;
    };
    systemd.services = mkOption {
      type = types.attrsOf (types.submodule (
        {name, config, ...}: {
          config = {
            serviceConfig.InacessibleDirectories = forbiddenPaths;
          };
        }
      ));
    };
    systemd.user.services = mkOption {
      type = types.attrsOf (types.submodule (
        {name, config, ...}: {
          config = {
            serviceConfig.InacessibleDirectories = forbiddenPaths;
          };
        }
      ));
    };
  };
}
