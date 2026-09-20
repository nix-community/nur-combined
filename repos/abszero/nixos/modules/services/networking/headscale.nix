{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (builtins)
    concatStringsSep
    elemAt
    getAttr
    attrValues
    ;
  inherit (lib) mkEnableOption mkIf pipe;
  cfg = config.abszero.services.headscale;

  url = "headscale.${config.networking.domain}";
  addrs = pipe config.abszero.networking.addrs [
    attrValues
    (map (getAttr "addr"))
  ];
in

{
  options.abszero.services.headscale.enable =
    mkEnableOption "Headscale Tailscale cooordination server";

  config.services = mkIf cfg.enable {
    caddy = {
      enable = true;
      openFirewall = true;
      globalConfig = ''
        # Fix TLS internal error caused by IP access without SNI
        # https://szo.cc/2026/06/enable-ip-cert-in-caddy
        default_sni ${elemAt addrs 0}
      '';
      extraConfig = ''
        # HTTPS - IP certificate
        ${concatStringsSep " " addrs} {
          tls {
            issuer acme {
              profile shortlived # IP cert must be shortlived
            }
          }
        }

        # HTTP - Headscale
        http://${url} {
          # Tailscale captive portal detection
          handle /generate_204 {
            respond 204
          }

          handle * {
            redir https://{host}{uri}
          }
        }

        # HTTPS - Headscale
        ${url} {
          reverse_proxy 127.0.0.1:${toString config.services.headscale.port} {
            header_up True-Client-IP {remote_host}
            header_up X-Real-IP {remote_host}
          }
        }
      '';
    };
    headscale = {
      enable = true;
      settings = {
        server_url = "https://${url}";
        dns = {
          base_domain = "ts.net";
          # Since the server uses bare resolv.conf, Headscale overwrites it with
          # its own DNS server. Set Headscale to use the declared DNS servers.
          nameservers.global = config.networking.nameservers;
          override_local_dns = false;
        };
        policy = {
          mode = "file";
          path = (pkgs.formats.json { }).generate "policy.hujson" {
            tagOwners = {
              "tag:server" = [ ];
            };
          };
        };
      };
    };
  };
}
