{ pkgs
, config
, lib
, ...
}:
with lib;
let
  cfg = config.services.compose-up;
in
{
  options.services.compose-up = {
    instances = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption { type = types.str; };
          workingDirectory = mkOption {
            type = types.str;
            default = "/none";
          };
        };
      });
      default = [ ];
    };
  };
  config =
    mkIf (cfg.instances != [ ])

      {
        systemd.services = lib.foldr
          (s: acc: acc // {
            "compose-up-${s.name}" = {
              wantedBy = [ "multi-user.target" ];
              after = [ "network-online.target" ];
              wants = [ "network-online.target" ];
              description = "compose-up daemon";
              serviceConfig =
                {
                  User = "root";
                  WorkingDirectory = s.workingDirectory;
                  ExecStart = "${lib.getExe' pkgs.docker-compose "docker-compose"} up";
                  Restart = "on-failure";
                };
            };
          })
          { }
          cfg.instances;
      }
  ;
}
