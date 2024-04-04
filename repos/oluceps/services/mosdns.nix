{ inputs, config, ... }:
{
  enable = true;
  config = {
    log = {
      level = "debug";
      production = false;
    };
    api.http = "localhost:9092";
    plugins =
      let
        src = "${inputs.nixyDomains}/assets";
      in
      [
        {
          args = {
            files = [ "${src}/accelerated-domains.china.txt" ];
          };
          tag = "direct_domain";
          type = "domain_set";
        }
        {
          args = {
            files = [ "${src}/all_cn.txt" ];
          };
          tag = "direct_ip";
          type = "ip_set";
        }
        {
          args = {
            dump_file = "./cache.dump";
            lazy_cache_ttl = 86400;
            size = 65536;
            dump_interval = 600;
          };
          tag = "cache";
          type = "cache";
        }
        {
          args = {
            concurrent = 2;
            upstreams = [
              { addr = "https://1.0.0.1/dns-query"; }
              {
                addr = "tls://8.8.4.4:853";
                enable_pipeline = true;
              }
            ];
          };
          tag = "remote_forward";
          type = "forward";
        }
        {
          args = {
            concurrent = 2;
            upstreams = [
              {
                addr = "quic://dns.alidns.com";
                dial_addr = "223.6.6.6";
              }
              {
                addr = "tls://dot.pub";
                dial_addr = "1.12.12.12";
                enable_pipeline = true;
              }
            ];
          };
          tag = "local_forward";
          type = "forward";
        }
        {
          args = {
            concurrent = 2;
            upstreams = [ { addr = "udp://192.168.1.1"; } ];
          };
          tag = "local_domain_forward";
          type = "forward";
        }
        {
          args = [
            { exec = "ttl 600-3600"; }
            { exec = "accept"; }
          ];
          tag = "ttl_sequence";
          type = "sequence";
        }
        {
          args = [
            { exec = "query_summary local_forward"; }
            { exec = "$local_forward"; }
            { exec = "goto ttl_sequence"; }
          ];
          tag = "local_sequence";
          type = "sequence";
        }
        {
          args = [
            { exec = "query_summary local_area"; }
            { exec = "$local_domain_forward"; }
            { exec = "goto ttl_sequence"; }
          ];
          tag = "local_area";
          type = "sequence";
        }
        {
          args = [
            { exec = "query_summary remote_forward"; }
            { exec = "$remote_forward"; }
            {
              exec = "goto local_sequence";
              matches = "resp_ip $direct_ip";
            }
            { exec = "goto ttl_sequence"; }
          ];
          tag = "remote_sequence";
          type = "sequence";
        }
        {
          args = {
            always_standby = false;
            primary = "remote_sequence";
            secondary = "local_sequence";
            threshold = 500;
          };
          tag = "final";
          type = "fallback";
        }
        {
          args = [
            { exec = "prefer_ipv4"; }
            { exec = "$cache"; }
            {
              exec = "accept";
              matches = "has_resp";
            }
            {
              exec = "$local_domain_forward";
              matches = "qname ${
                with builtins;
                (concatStringsSep " " (map (n: "full:" + n + ".") (attrNames inputs.self.nixosConfigurations)))
              }";
            }
            {
              exec = "accept";
              matches = "has_resp";
            }
            {
              exec = "goto local_sequence";
              matches = "qname $direct_domain";
            }
            { exec = "$final"; }
          ];
          tag = "main_sequence";
          type = "sequence";
        }
        {
          args = {
            entry = "main_sequence";
            listen = ":53";
          };
          tag = "udp_server";
          type = "udp_server";
        }
        {
          args = {
            entry = "main_sequence";
            listen = ":53";
          };
          tag = "tcp_server";
          type = "tcp_server";
        }
        {
          tag = "quic_server";
          type = "quic_server";
          args = {
            entry = "main_sequence";
            listen = "127.0.0.1:853";
            cert = config.age.secrets."nyaw.cert".path;
            key = config.age.secrets."nyaw.key".path;
            idle_timeout = 30;
          };
        }
      ];
  };
}
