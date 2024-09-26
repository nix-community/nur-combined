{ reIf, ... }:
reIf {
  services.dnsproxy = {
    enable = true;
    flags = [
      "--cache"
      "--cache-optimistic"
      "--edns"
      "--http3"
    ];
    settings = {
      bootstrap = [
        "119.29.29.29"
        "tcp://223.6.6.6:53"
      ];
      listen-addrs = [ "0.0.0.0" ];
      listen-ports = [ 53 ];
      upstream-mode = "parallel";
      upstream = [
        "quic://dns.alidns.com"
        "1.1.1.1"
        "h3://dns.alidns.com/dns-query"
        "tls://dot.pub"
      ];
    };
  };
}
