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
    systemd.services.dnsproxy.serviceConfig = {
      LoadCredential = lib.mkIf cfg.loadCert (
        (map (lib.genCredPath config)) [
          "nyaw.cert"
          "nyaw.key"
        ]
      );
      TimeoutStopSec = "10s";
    };
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
          "tls://1.1.1.1"
          "tls://1.0.0.1"
        ];
        listen-addrs = [ "::" ];
        listen-ports = [ 53 ];
        upstream-mode = "parallel";
        upstream = [
          # "quic://unfiltered.adguard-dns.com"
          "quic://dns.alidns.com"
          "h3://dns.alidns.com/dns-query"
          "https://dns.google/dns-query"
          "tls://dot.pub"
          "tls://1.1.1.1"
        ];
      };
    };

  };
}
