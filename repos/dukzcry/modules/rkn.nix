{ config, lib, pkgs, ... }:

with lib;

let
  ip4 = pkgs.nur.repos.dukzcry.lib.ip4;
  cfg = config.services.rkn;
in {
  options.services.rkn = {
    enable = mkEnableOption "Обход блокировок роскомпозора";
    address = mkOption {
      type = types.str;
    };
    resolver = mkOption {
      type = types.submodule {
        options = {
          addresses = mkOption {
            type = types.listOf types.str;
          };
          ipv6 = mkOption {
            type = types.bool;
            default = false;
          };
        };
      };
    };
    tor = mkOption {
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
          };
          network = mkOption {
            type = ip4.type;
            default = ip4.fromString "10.123.0.1/16";
          };
          snowflake = mkEnableOption "транспорт Snowflake";
        };
      };
    default = {};
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.dnsmasq.enable = true;
      services.dnsmasq.extraConfig = ''
        conf-file=/var/lib/dnsmasq/rkn
      '';
      # в отличие от решения с голым ipset
      # 1) разные сайты с одним IP не задевают друг друга
      # 2) при удалённом использовании не надо гнать весь трафик через VPN
      services.nginx.enable = true;
      services.nginx.proxyResolveWhileRunning = true;
      services.nginx.resolver = {
        addresses = cfg.resolver.addresses;
        ipv6 = cfg.resolver.ipv6;
      };
      services.nginx.virtualHosts = {
        rkn = {
          default = true;
          listen = [{ addr = cfg.address; port = 80; }];
          locations."/" = {
            proxyPass = "http://$http_host:80";
            extraConfig = ''
              proxy_bind ${cfg.address};
            '';
          };
        };
      };
      services.nginx.streamConfig = ''
        server {
          resolver ${toString cfg.resolver.addresses} ${optionalString (!cfg.resolver.ipv6) "ipv6=off"};
          listen ${cfg.address}:443;
          ssl_preread on;
          proxy_pass $ssl_preread_server_name:443;
          proxy_bind ${cfg.address};
        }
      '';
    })
    (mkIf (cfg.enable && cfg.tor.enable) {
      services.tor.enable = true;
      services.tor.client.enable = true;
      services.tor.settings = ({
        ExcludeExitNodes = "{RU}";
        # onion
        DNSPort = [{ addr = cfg.address; port = 9053; }];
        VirtualAddrNetworkIPv4 = ip4.networkCIDR cfg.tor.network;
        AutomapHostsOnResolve = true;
        TransPort = [{ addr = cfg.address; port = 9040; }];
      } // optionalAttrs cfg.tor.snowflake {
        UseBridges = true;
        Bridge = "snowflake 192.0.2.3:1";
        ClientTransportPlugin = ''
          snowflake exec ${pkgs.snowflake}/bin/client \
            -url https://snowflake-broker.azureedge.net/ \
            -front ajax.aspnetcdn.com \
            -ice stun:stun.l.google.com:19302 \
            -max 3
        '';
      });
      networking.firewall.extraCommands = ''
        iptables -t nat -A OUTPUT -p tcp -m multiport --dports 80,443 -s ${cfg.address} -j DNAT --to-destination ${cfg.address}:9040
        # onion
        iptables -t nat -A PREROUTING -p tcp -m multiport --dports 80,443 -d ${ip4.networkCIDR cfg.tor.network} -j DNAT --to-destination ${cfg.address}:9040
        iptables -t nat -A OUTPUT -p tcp -m multiport --dports 80,443 -d ${ip4.networkCIDR cfg.tor.network} -j DNAT --to-destination ${cfg.address}:9040
      '';
      services.dnsmasq.extraConfig = ''
        server=/onion/${cfg.address}#9053
        rebind-domain-ok=onion
      '';
    })
  ];
}
