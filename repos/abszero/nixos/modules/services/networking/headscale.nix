{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mapAttrsToList;
  cfg = config.abszero.services.headscale;

  domain = config.networking.domain;
  url = "headscale.${domain}";
in

{
  options.abszero.services.headscale.enable =
    mkEnableOption "Headscale Tailscale cooordination server";

  config.services = mkIf cfg.enable {
    caddy = {
      enable = true;
      openFirewall = true;
      extraConfig = ''
        http://${url} {
          # Tailscale captive portal detection
          handle /generate_204 {
            respond 204
          }

          handle * {
            redir https://{host}{uri}
          }
        }

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
        dns = {
          base_domain = domain;
          server_url = "https://${url}";
          # For some reason, Headscale DNS cannot resolve its own domain
          extra_records = mapAttrsToList (_: addr: {
            name = domain;
            type = if addr.type == "ipv4" then "A" else "AAAA";
            value = addr.addr;
          }) config.abszero.networking.addrs;
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
