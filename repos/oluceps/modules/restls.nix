{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.restls;
in
{
  options.services.restls = {
    instances = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption { type = types.str; };
            package = mkPackageOption pkgs "restls" { };
            serve = mkOption {
              type = types.submodule {
                options = {
                  enable = mkEnableOption (lib.mdDoc "server");
                  port = mkOption { type = types.port; };
                };
              };
              default = {
                enable = false;
                port = 0;
              };
            };
            environmentFile = mkOption {
              type = types.str;
              default = "/none";
            };
          };
        }
      );
      default = [ ];
    };
  };

  config = mkIf (cfg.instances != [ ]) {

    environment.systemPackages = lib.unique (
      lib.foldr (s: acc: acc ++ [ s.package ]) [ ] cfg.instances
    );

    networking.firewall = (
      lib.foldr (
        s: acc: acc // { allowedUDPPorts = mkIf s.serve.enable [ s.serve.port ]; }
      ) { } cfg.instances
    );

    systemd.services = lib.foldr (
      s: acc:
      acc
      // {
        "restls-${s.name}" = {
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          description = "restls daemon";
          serviceConfig = {
            Type = "simple";
            User = "proxy";
            ExecStart = "${s.package}/bin/restls -s $SERVER_HOSTNAME -l $LISTEN -p $PASSWORD -f $FORWARD_TO --script $SCRIPT";
            AmbientCapabilities = [
              "CAP_NET_ADMIN"
              "CAP_NET_BIND_SERVICE"
            ];
            Restart = "on-failure";
          };
        };
      }
    ) { } cfg.instances;
  };
}
