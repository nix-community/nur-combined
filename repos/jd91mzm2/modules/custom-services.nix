{ config, lib, ... }:

with lib;

let
  cfgs = config.custom.services;
in
{
  options.custom.services = mkOption {
    default = {};
    description = ''
      Custom scripts that should get their own dedicated user and
      service.
    '';
    example = {
      my-service.script = "sleep 1000";
    };
    type = types.attrsOf (types.submodule ({ config, name, ... }: {
      options = {
        name = mkOption {
          type = types.str;
          default = name;
          description = ''
            The name of the service. Defaults to the key.
          '';
        };
        autoStart = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether or not to auto-start the service on boot.
          '';
        };
        group = mkOption {
          type = types.str;
          default = "nogroup";
          example = "keys";
          description = ''
            Which group the user should be in. The default is "nogroup", but you
            can use "keys" in order to grant the user access to secrets.
          '';
        };
        script = mkOption {
          type = types.str;
          example = "sleep 1000";
          description = ''
            The script that should run once this service is started.
          '';
        };
      };
    }));
  };
  config = {
    users.users = listToAttrs (
      map
        (cfg: nameValuePair cfg.name {
          createHome = true;
          home = "/var/lib/${cfg.name}";
          inherit (cfg) group;
        })
        (builtins.attrValues cfgs)
    );
    systemd.services = listToAttrs (
      map
        (cfg: nameValuePair cfg.name {
          script = cfg.script;
          serviceConfig = {
            User = cfg.name;
            WorkingDirectory = "/var/lib/${cfg.name}";
            Restart = "always";
            RestartSec = "10s";
          };
          wantedBy = if cfg.autoStart then [ "multi-user.target" ] else [];
        })
        (builtins.attrValues cfgs)
    );
  };
}
