{ config, lib, pkgs, ... }:
let
  wgCfg = config.my.services.wireguard;
  cfg = config.my.services.adblock;
in
{
  options.my.services.adblock = with lib; {
    enable = mkEnableOption "Hosts-based adblock using unbound";

    forwardAddresses = mkOption {
      type = with types; listOf str;
      default = [
        "1.0.0.1@853#cloudflare-dns.com"
        "1.1.1.1@853#cloudflare-dns.com"
      ];
      example = [
        "8.8.4.4"
        "8.8.8.8"
      ];
      description = "Which DNS servers to forward queries to";
    };

    interfaces = mkOption {
      type = with types; listOf str;
      default = [
        "0.0.0.0"
        "::"
      ];
      example = literalExample ''
        [
          "127.0.0.1"
        ]
      '';
      description = "Which addresses to listen on";
    };
  };

  config = lib.mkIf cfg.enable {
    # Allow wireguard clients to connect to it
    networking.firewall.interfaces."${wgCfg.iface}" = {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };

    services.unbound = {
      enable = true;

      allowedAccess = [
        "127.0.0.0/24"
        "${wgCfg.net.v4.subnet}.0/${toString wgCfg.net.v4.mask}"
        "${wgCfg.net.v6.subnet}::0/${toString wgCfg.net.v6.mask}"
      ];

      inherit (cfg) forwardAddresses interfaces;

      extraConfig = ''
        so-reuseport: yes
        tls-cert-bundle: /etc/ssl/certs/ca-certificates.crt
        tls-upstream: yes

        include: "${pkgs.ambroisie.unbound-zones-adblock}/hosts"
      '';
    };
  };
}
