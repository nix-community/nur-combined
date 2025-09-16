# original from NickCao/flakes
{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.repack.caddy;
  format = pkgs.formats.json { };
  configfile = format.generate "config.json" cfg.settings;
in
{

  options = {
    repack.caddy = {
      # moved to upper module
      # enable = lib.mkEnableOption "caddy api gateway";
      # mkPackageOption not work here
      expose = lib.mkEnableOption "API env";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.caddy.withPlugins {
          plugins = [
            "github.com/caddy-dns/cloudflare@v0.0.0-20250724223520-f589a18c0f5d"
            "github.com/mholt/caddy-ratelimit@v0.1.0"
            "github.com/ss098/certmagic-s3@v0.0.0-20250607141218-0c4ff782fbd0"
          ];
          hash = "sha256-/HyaYO6Tslp4OVMjnb0ucA9FFtWethcnBqiQlMOEqWU=";
        };
      };
      settings = lib.mkOption {
        type = lib.types.submodule { freeformType = format.type; };
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    repack.caddy.settings = {
      admin = {
        config.persist = false;
      };
      logging.logs.debug.level = "debug";
      storage = mkIf cfg.expose {
        module = "s3";
        prefix = "ssl";
        insecure = false;
      };
      apps = {
        http.grace_period = "1s";
        http.servers.srv0 = {
          listen = [ ":443" ];
          strict_sni_host = false;
          automatic_https = {
            skip_certificates = [
            ];
          };
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
          EnvironmentFile = mkIf cfg.expose config.vaultix.secrets.caddy.path;
          LoadCredential = mkIf (!cfg.expose) (
            (map (lib.genCredPath config)) [
              "nyaw.cert"
              "nyaw.key"
            ]
          );
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
