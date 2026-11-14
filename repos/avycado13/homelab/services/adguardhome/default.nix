{ config, lib, ... }:
let
  cfg = config.homelab.services.adguardhome;
  hl = config.homelab;
  webPort = 3000;
in
{
  options.homelab.services.adguardhome = {
    enable = lib.mkEnableOption "AdGuard Home DNS filtering";

    dnsInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "tailscale0" ];
      example = [
        "wlan0"
        "tailscale0"
      ];
      description = "Interfaces allowed to reach AdGuard Home on DNS port 53. Add the LAN interface to serve local clients; do not expose an open resolver to the internet.";
    };

    gatus = import ../../lib/gatusEndpoint.nix {
      inherit lib;
      name = "AdGuard Home";
      url = "http://127.0.0.1:${toString webPort}/";
    };
  };

  config = lib.mkIf (hl.services.enable && cfg.enable) {
    services.adguardhome = {
      enable = true;
      # Keep the setup wizard and admin UI off the public Caddy reverse proxy.
      # Access via SSH port forwarding to localhost:3000 instead.
      settings = {
        http.address = "127.0.0.1:${toString webPort}";
        dns = {
          bind_hosts = [
            "0.0.0.0"
            "::"
          ];
          port = 53;
          upstream_dns = [ "https://dns.cloudflare.com/dns-query" ];
          bootstrap_dns = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        };
      };
    };

    networking.firewall.interfaces = lib.genAttrs cfg.dnsInterfaces (_: {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    });

    systemd.services.adguardhome.unitConfig.OnFailure = lib.mkIf (
      hl.notifications.ntfySecretsFile != null
    ) "notify-failure@%n.service";
  };
}
