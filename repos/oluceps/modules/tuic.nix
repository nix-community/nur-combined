{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.tuic;
in
{
  disabledModules = [ "services/networking/tuic.nix" ];
  options.services.tuic = {
    instances = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption { type = types.str; };
            package = mkPackageOption pkgs "tuic" { };
            serve = mkEnableOption (lib.mdDoc "server");
            configFile = mkOption {
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
    systemd.services = lib.foldr (
      s: acc:
      acc
      // {
        "tuic-${s.name}" = {
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          description = "tuic daemon";
          serviceConfig =
            let
              binSuffix = if s.serve then "server" else "client";
            in
            {
              Type = "simple";
              User = "proxy";
              ExecStart = "${s.package}/bin/tuic-${binSuffix} -c ${s.configFile}";
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
