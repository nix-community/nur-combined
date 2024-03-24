{ inputs, ... }:
let
  redisPort = 6380;
  src = "${inputs.nixyDomains}/assets";
in
{
  enable = true;
  inherit redisPort;
  config = {
    cache = {
      maximum_ttl = 3600;
      mem_size = 1048576;
      redis = "unix:///run/redis-mosproxy/redis.sock";
    };
    metrics = { addr = "0.0.0.0:9092"; };
    ecs = { enabled = false; };
    log = { queries = true; };
    domain_sets = [{ files = [ "${src}/accelerated-domains.gfw.txt" ]; tag = "gfw"; }];

    rules = [
      { domain = "gfw"; forward = "ggl"; reject = 0; reverse = false; }
      { domain = "gfw"; forward = "one"; reject = 0; reverse = false; }
      { forward = "ali"; reject = 0; }
      { forward = "dot"; reject = 0; }
    ];
    servers = [
      {
        listen = "127.0.0.1:53";
        protocol = "udp";
        quic = { max_streams = 100; };
        udp = { multi_routes = false; };
      }
      {
        listen = "127.0.0.1:53";
        protocol = "gnet";
        tcp = { max_concurrent_queries = 100; };
      }
    ];
    upstreams = [
      {
        addr = "https://dns.google/dns-query";
        dial_addr = "8.8.8.8";
        tag = "ggl";
      }
      {
        addr = "tls+pipeline://1.1.1.1:853";
        tag = "one";
      }
      {
        addr = "quic://dns.alidns.com";
        dial_addr = "223.6.6.6";
        tag = "ali";
      }
      {
        addr = "tls+pipeline://dot.pub";
        dial_addr = "1.12.12.12";
        tag = "dot";
      }
    ];
  };
}
