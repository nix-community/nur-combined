{ ... }:
let
  redisPort = 6380;
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
    api = {
      addr = "0.0.0.0:9092";
    };
    ecs = {
      enabled = true;
    };
    log = {
      queries = true;
    };

    rules = [
      {
        forward = "ali";
        reject = 0;
      }
      {
        forward = "dot";
        reject = 0;
      }
    ];
    servers = [
      {
        listen = "[::]:53";
        protocol = "udp";
        quic = {
          max_streams = 100;
        };
        udp = {
          multi_routes = false;
        };
      }
      {
        listen = "[::]:53";
        protocol = "gnet";
        tcp = {
          max_concurrent_queries = 100;
        };
      }
    ];
    upstreams = [
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
