{ lib, config, ... }:
let
  cfg = config.repack.dnsproxy;
  inherit (lib) mkIf;
in
{
  options = {
    repack.dnsproxy = {
      extraFlags = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };
      loadCert = lib.mkEnableOption { };
      lazy = lib.mkEnableOption { };
    };
  };
  config = lib.mkIf cfg.enable {
    # systemd.services.dnsproxy.unitConfig.Conflicts = [ "sing-box.service" ];
    systemd.services.dnsproxy.wantedBy = mkIf (!cfg.lazy) [ "multi-user.target" ];
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
      ]
      ++ cfg.extraFlags;
      settings = {
        bootstrap = [
          "8.8.8.8"
          "119.29.29.29"
          "114.114.114.114"
          "223.6.6.6"
        ];
        listen-addrs = [ "::" ];
        listen-ports = [ 53 ];
        upstream-mode = "parallel";
        upstream =
          if (lib.getThisNodeFrom config).censor then
            [
              "quic://dns.alidns.com"
              "h3://dns.alidns.com/dns-query"
              "tls://dot.pub"
              "https://doh.pub/dns-query"
              # "tls://1.1.1.1"
              # "https://dns.google/dns-query" # banned since 5 Mar
            ]
          else
            [
              "quic://unfiltered.adguard-dns.com"
              "tls://1.1.1.1"
              "tls://1.0.0.1"
              "https://dns.google/dns-query"
            ];
      };
    };

  };
}
