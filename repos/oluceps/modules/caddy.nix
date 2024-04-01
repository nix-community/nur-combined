# original from NickCao/flakes
{ pkgs, config, lib, ... }:
let
  cfg = config.repack.caddy;
  format = pkgs.formats.json { };
  configfile = format.generate "config.json" cfg.settings;
in
{

  options = {
    repack.caddy = {
      enable = lib.mkEnableOption "caddy api gateway";
      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = format.type;
        };
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
      logging.logs.debug.level = "debug";
      apps = {
        http.grace_period = "1s";
        http.servers.srv0 = {
          listen = [ ":443" ];
          strict_sni_host = false;
          routes = [
            {
              match = [{
                host = [ config.networking.fqdn ];
                path = [ "/prom" "/prom/*" ];
              }];
              handle = [
                {
                  handler = "authentication";
                  providers.http_basic.accounts = [{
                    username = "prometheus";
                    password = "$2b$05$eZjq0oUqZzxgqdRaCRsKROuE96w9Y0aKSri3uGPccckPivESAinB6";
                  }];
                }
                {
                  handler = "reverse_proxy";
                  upstreams = [{ dial = "10.0.1.2:9090"; }];
                }
              ];
            }
            {
              match = [{
                host = [ config.networking.fqdn ];
                path = [ "/caddy" ];
              }];
              handle = [
                {
                  handler = "authentication";
                  providers.http_basic.accounts = [{
                    username = "prometheus";
                    password = "$2b$05$bKuO7ehC6wKR28/pfhJZOuNyQFUtF7FwhkPFLwcbCMhfLRNUV54vm";
                  }];
                }
                {
                  handler = "metrics";
                }
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

    systemd.services.caddy = {
      serviceConfig = {
        Type = "notify";
        ExecStart = "${pkgs.caddy}/bin/caddy run --config /etc/caddy/config.json";
        ExecReload = "${pkgs.caddy}/bin/caddy reload --force --config /etc/caddy/config.json";
        DynamicUser = true;
        StateDirectory = "caddy";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        Environment = [ "XDG_DATA_HOME=%S" ];
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "network-online.target" ];
      requires = [ "network-online.target" ];
      reloadTriggers = [ configfile ];
    };
  };

}
