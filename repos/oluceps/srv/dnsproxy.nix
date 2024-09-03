{ ... }:
{
  enable = true;
  flags = [
    "--cache"
    "--edns"
    "--http3"
  ];
  settings = {
    bootstrap = [
      "1.1.1.1"
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
}
