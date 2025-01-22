# original from NickCao/flakes
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.repack.caddy;
  format = pkgs.formats.json { };
  configfile = format.generate "config.json" cfg.settings;
in
{

  options = {
    repack.caddy = {
      # moved to upper module
      # enable = lib.mkEnableOption "caddy api gateway";
      package = lib.mkPackageOption pkgs "caddy-lim" { };
      settings = lib.mkOption {
        type = lib.types.submodule { freeformType = format.type; };
        default = { };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    repack.caddy.settings = {
      admin = {
        listen = "unix//tmp/caddy.sock";
        config.persist = false;
      };
      # logging.logs.debug.level = "debug";
      apps = {
        http.grace_period = "1s";
        http.servers.srv0 = {
          listen = [ ":443" ];
          strict_sni_host = false;
          routes = [
            {
              match = [
                {
                  host = [ config.networking.fqdn ];
                  path = [ "/caddy" ];
                }
              ];
              handle = [
                {
                  handler = "authentication";
                  providers.http_basic.accounts = [
                    {
                      username = "prometheus";
                      password = "$2b$05$9CaXvrYtguDwi190/llO9.qytgqCyPp1wqyO0.umxsTEfKkhpwr4q";
                    }
                  ];
                }
                { handler = "metrics"; }
              ];
            }
          ];
          metrics = { };
        };
        tls = {
          automation = {
            policies = [
              {
                key_type = "p256";
                issuers = [
                  {
                    email = "mn1.674927211@gmail.com";
                    module = "acme";
                  }
                ];
              }
            ];
          };
          # certificates = {
          #   load_files = [{
          #     certificate = "/run/credentials/caddy.service/nyaw.cert";
          #     key = "/run/credentials/caddy.service/nyaw.key";
          #     tags = [ "cert0" ];
          #   }];
          # };
        };
      };
    };

    environment.etc."caddy/config.json".source = configfile;
    environment.systemPackages = [ cfg.package ];

    systemd.services.caddy = {
      preStart = "cp -f /etc/caddy/config.json /var/lib/caddy/backup.json";
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      serviceConfig =
        let
          caddyBin = "${cfg.package}/bin/caddy";
        in
        {
          Type = "notify";
          ExecStartPre = "${caddyBin} validate --config /etc/caddy/config.json";
          ExecStart = "${caddyBin} run --config /etc/caddy/config.json";
          ExecReload = "${caddyBin} reload --force --config /etc/caddy/config.json";
          DynamicUser = true;
          StateDirectory = "caddy";
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          Environment = [ "XDG_DATA_HOME=%S" ];
          Restart = "always";
          RestartSec = 1;
        };
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "network-online.target"
      ];
      requires = [ "network-online.target" ];
      reloadTriggers = [ configfile ];
    };
  };
}
