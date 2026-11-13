{
  config,
  pkgs,
  ...
}:
{
  sops.secrets = {
    sing_box_server_ip = { };
    sing_box_server_name = { };
    sing_box_server_uuid = { };
    sing_box_server_path = { };
  };
  services.sing-box = {
    enable = true;
    settings = {
      "$schema" = "https://sing-box.sagernet.org/schema.json";
      dns = {
        final = "proxy-dns";
        rules = [
          {
            action = "predefined";
            query_type = [
              "AAAA"
              "HTTPS"
              "SVCB"
            ];
            rcode = "NOERROR";
          }
          {
            action = "route";
            clash_mode = "Direct";
            server = "direct-dns";
          }
          {
            action = "route";
            clash_mode = "Global";
            server = "proxy-dns";
          }
          {
            action = "route";
            rule_set = "geosite-cn";
            server = "direct-dns";
          }
          {
            action = "route";
            rule_set = "geolocation-!cn";
            server = "proxy-dns";
          }
        ];
        servers = [
          {
            domain_resolver = "direct-dns-bootstrap";
            server = "223.5.5.5";
            tag = "direct-dns";
            type = "https";
          }
          {
            server = "223.5.5.5";
            tag = "direct-dns-bootstrap";
            type = "udp";
          }
          {
            detour = "select";
            server = "8.8.8.8";
            tag = "proxy-dns";
            type = "https";
          }
        ];
        strategy = "ipv4_only";
      };
      experimental = {
        cache_file = {
          cache_id = "linux-1.14-mixed";
          enabled = true;
        };
        clash_api = {
          default_mode = "Rule";
        };
      };
      http_clients = [
        {
          domain_resolver = {
            server = "direct-dns-bootstrap";
            strategy = "ipv4_only";
          };
          tag = "rule-set-direct";
        }
      ];
      inbounds = [
        {
          listen = "127.0.0.1";
          listen_port = 7890;
          set_system_proxy = false;
          tag = "mixed-in";
          type = "mixed";
        }
      ];
      log = {
        disabled = false;
        level = "warn";
        timestamp = true;
      };
      outbounds = [
        {
          server._secret = config.sops.secrets.sing_box_server_ip.path;
          server_port = 443;
          tag = "proxy";
          tls = {
            enabled = true;
            server_name._secret = config.sops.secrets.sing_box_server_name.path;
          };
          transport = {
            headers.Host._secret = config.sops.secrets.sing_box_server_name.path;
            path._secret = config.sops.secrets.sing_box_server_path.path;
            type = "httpupgrade";
          };
          type = "vless";
          uuid._secret = config.sops.secrets.sing_box_server_uuid.path;
        }
        {
          default = "auto";
          outbounds = [
            "auto"
            "proxy"
          ];
          tag = "select";
          type = "selector";
        }
        {
          interrupt_exist_connections = false;
          interval = "10m";
          outbounds = [ "proxy" ];
          tag = "auto";
          tolerance = 150;
          type = "urltest";
          url = "https://www.gstatic.com/generate_204";
        }
        {
          default = "select";
          interrupt_exist_connections = false;
          outbounds = [
            "select"
            "auto"
            "direct"
            "proxy"
          ];
          tag = "streaming";
          type = "selector";
        }
        {
          default = "select";
          interrupt_exist_connections = false;
          outbounds = [
            "select"
            "auto"
            "direct"
            "proxy"
          ];
          tag = "ai";
          type = "selector";
        }
        {
          default = "select";
          interrupt_exist_connections = false;
          outbounds = [
            "select"
            "auto"
            "direct"
            "proxy"
          ];
          tag = "telegram";
          type = "selector";
        }
        {
          default = "select";
          interrupt_exist_connections = false;
          outbounds = [
            "select"
            "auto"
            "direct"
            "proxy"
          ];
          tag = "microsoft";
          type = "selector";
        }
        {
          default = "select";
          interrupt_exist_connections = false;
          outbounds = [
            "select"
            "auto"
            "direct"
            "proxy"
          ];
          tag = "apple";
          type = "selector";
        }
        {
          default = "select";
          interrupt_exist_connections = false;
          outbounds = [
            "select"
            "auto"
            "direct"
            "proxy"
          ];
          tag = "google";
          type = "selector";
        }
        {
          default = "select";
          interrupt_exist_connections = false;
          outbounds = [
            "select"
            "auto"
            "direct"
            "proxy"
          ];
          tag = "github";
          type = "selector";
        }
        {
          tag = "direct";
          type = "direct";
        }
        {
          default = "select";
          interrupt_exist_connections = false;
          outbounds = [
            "select"
            "auto"
            "proxy"
            "direct"
          ];
          tag = "GLOBAL";
          type = "selector";
        }
      ];
      route = {
        auto_detect_interface = true;
        default_domain_resolver = {
          server = "direct-dns";
        };
        default_http_client = "rule-set-direct";
        final = "select";
        rule_set = [
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "geosite-private";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/private.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "geoip-cn";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/cn.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "geosite-cn";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/cn.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "geolocation-!cn";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/geolocation-!cn.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "category-ai-!cn";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/category-ai-!cn.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "youtube";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/youtube.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "netflix";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/netflix.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "disney";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/disney.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "spotify";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/spotify.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "tiktok";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/tiktok.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "telegram";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/telegram.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "microsoft";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/microsoft.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "onedrive";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/onedrive.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "apple";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/apple.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "google";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/google.srs";
          }
          {
            format = "binary";
            http_client = "rule-set-direct";
            tag = "github";
            type = "remote";
            url = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/github.srs";
          }
        ];
        rules = [
          { action = "sniff"; }
          {
            action = "resolve";
            strategy = "ipv4_only";
          }
          {
            action = "reject";
            ip_version = 6;
          }
          {
            action = "route";
            ip_is_private = true;
            outbound = "direct";
          }
          {
            action = "route";
            clash_mode = "Direct";
            outbound = "direct";
          }
          {
            action = "route";
            clash_mode = "Global";
            outbound = "GLOBAL";
          }
          {
            action = "route";
            outbound = "direct";
            rule_set = "geosite-private";
          }
          {
            action = "route";
            outbound = "direct";
            rule_set = "geosite-cn";
          }
          {
            action = "route";
            mode = "and";
            outbound = "direct";
            rules = [
              { rule_set = "geoip-cn"; }
              {
                invert = true;
                rule_set = "geolocation-!cn";
              }
            ];
            type = "logical";
          }
          {
            action = "route";
            outbound = "ai";
            rule_set = "category-ai-!cn";
          }
          {
            action = "route";
            outbound = "streaming";
            rule_set = "youtube";
          }
          {
            action = "route";
            outbound = "streaming";
            rule_set = "netflix";
          }
          {
            action = "route";
            outbound = "streaming";
            rule_set = "disney";
          }
          {
            action = "route";
            outbound = "streaming";
            rule_set = "spotify";
          }
          {
            action = "route";
            outbound = "streaming";
            rule_set = "tiktok";
          }
          {
            action = "route";
            outbound = "telegram";
            rule_set = "telegram";
          }
          {
            action = "route";
            outbound = "microsoft";
            rule_set = "microsoft";
          }
          {
            action = "route";
            outbound = "microsoft";
            rule_set = "onedrive";
          }
          {
            action = "route";
            outbound = "apple";
            rule_set = "apple";
          }
          {
            action = "route";
            outbound = "google";
            rule_set = "google";
          }
          {
            action = "route";
            outbound = "github";
            rule_set = "github";
          }
          {
            action = "route";
            outbound = "select";
            rule_set = "geolocation-!cn";
          }
        ];
      };
    };
  };
  programs.proxychains = {
    enable = true;
    package = pkgs.proxychains-ng;
    proxies = {
      sing-box = {
        enable = true;
        host = "127.0.0.1";
        port = 7890;
        type = "http";
      };
    };
    proxyDNS = false;
  };
}
