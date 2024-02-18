{ utils, pkgs, config, lib, ... }:
let
  cfg = config.cloud.caddy;
  format = pkgs.formats.json { };
in
{

  options = {
    cloud.caddy = {
      enable = lib.mkEnableOption "caddy api gateway";
      package = lib.mkPackageOption pkgs "caddy" { };
      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = format.type;
        };
        default = { };
      };
    };
  };

  config = lib.mkIf cfg.enable {

    cloud.caddy.settings = {
      admin = {
        listen = "unix//tmp/caddy.sock";
        config.persist = false;
      };
      apps = {
        tls.automation.policies = [{
          key_type = "p256";
        }];
        http.grace_period = "1s";
      };
    };
    systemd.services.caddy = {

      serviceConfig = {
        Type = "notify";
        ExecStartPre = pkgs.writeShellScript "init-caddy" ''
          set -euo pipefail
          umask u=rwx,g=,o=
          ${utils.genJqSecretsReplacementSnippet cfg.settings "/var/lib/caddy/config.json"}
        '';
        ExecStart = "${cfg.package}/bin/caddy run --config /var/lib/caddy/config.json";
        ExecReload = "${cfg.package}/bin/caddy reload --force --config /var/lib/caddy/config.json";
        # DynamicUser = true;
        User = "root";
        StateDirectory = "caddy";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        Environment = [ "XDG_DATA_HOME=%S" ];
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "network-online.target" ];
      requires = [ "network-online.target" ];
    };
  };

}
