{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.services.filesWatcher;
in
{
  options = {
    services.filesWatcher = with types; mkOption {
      default = {};
      description = ''
        Files to watch and trigger service reload or restart of service
        when changed.
        '';
        type = attrsOf (submodule {
          options = {
            restart = mkEnableOption "Restart service rather than reloading it";
            paths = mkOption {
              type = listOf str;
              description = ''
                Paths to watch that should trigger a reload of the
                service
                '';
            };
            waitTime = mkOption {
              type = int;
              default = 5;
              description = ''
                Time to wait before reloading/restarting the service.
                Set 0 to not wait.
                '';
            };
          };
      });
    };
  };

  config.systemd.services = attrsets.mapAttrs' (name: icfg: attrsets.nameValuePair
    "${name}Watcher" {
      description = "${name} reloader";
      after = [ "network.target" ];
      script = let
        action = if icfg.restart then "restart" else "reload";
      in ''
        # Service may be stopped during file modification (e.g. activationScripts)
        if ${pkgs.systemd}/bin/systemctl --quiet is-active ${name}.service; then
          ${pkgs.coreutils}/bin/sleep ${toString icfg.waitTime}
          ${pkgs.systemd}/bin/systemctl ${action} ${name}.service
        fi
        '';
      serviceConfig = {
        Type = "oneshot";
      };
    }
  ) cfg;
  config.systemd.paths = attrsets.mapAttrs' (name: icfg: attrsets.nameValuePair
    "${name}Watcher" {
      wantedBy = [ "multi-user.target" ];
      pathConfig.PathChanged = icfg.paths;
    }
  ) cfg;
}
