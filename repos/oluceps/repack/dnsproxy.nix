{ lib, config, ... }:
let
  cfg = config.repack.dnsproxy;
in
{
  options = {
    repack.dnsproxy = {
      extraFlags = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };
      loadCert = lib.mkEnableOption { };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.dnsproxy.serviceConfig.LoadCredential = lib.mkIf cfg.loadCert (
      (map (lib.genCredPath config)) [
        "nyaw.cert"
        "nyaw.key"
      ]
    );
    services.dnsproxy = {
      enable = true;
      flags = [
        "--cache"
        "--cache-optimistic"
        "--edns"
      ] ++ cfg.extraFlags;
      settings = {
        bootstrap = [
          "8.8.8.8"
          "119.29.29.29"
          "tcp://223.6.6.6:53"
        ];
        listen-addrs = [ "0.0.0.0" ];
        listen-ports = [ 53 ];
        upstream-mode = "parallel";
        upstream = [
          "quic://unfiltered.adguard-dns.com"
          "quic://dns.alidns.com"
          "sdns://AgcAAAAAAAAABzEuMC4wLjGgENk8mGSlIfMGXMOlIlCcKvq7AVgcrZxtjon911-ep0cg63Ul-I8NlFj4GplQGb_TTLiczclX57DvMV8Q-JdjgRgSZG5zLmNsb3VkZmxhcmUuY29tCi9kbnMtcXVlcnk"
          "h3://dns.alidns.com/dns-query"
          "tls://dot.pub"
        ];
      };
    };

  };
}
