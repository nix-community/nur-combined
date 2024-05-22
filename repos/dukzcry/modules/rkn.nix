{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.rkn;
in {
  options.services.rkn = {
    enable = mkEnableOption "Обход блокировок роскомпозора";
    address = mkOption {
      type = types.str;
    };
    address6 = mkOption {
      type = types.str;
      default = "";
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
            type = types.str;
          };
        };
      };
    default = {};
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.dnsmasq.enable = true;
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
          listen = [
            { addr = cfg.address; port = 80; }
          ] ++ optional (cfg.address6 != "") { addr = "[${cfg.address6}]"; port = 80; };
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
          ${optionalString (cfg.address6 != "") "listen [${cfg.address6}]:443;"}
          ssl_preread on;
          proxy_pass $ssl_preread_server_name:443;
          proxy_bind ${cfg.address};
        }
      '';
    })
    (mkIf (cfg.enable && cfg.tor.enable) {
      services.tor.enable = true;
      services.tor.settings = {
        ExcludeExitNodes = "{RU}";
        # onion
        DNSPort = [{ addr = cfg.address; port = 9053; }];
        VirtualAddrNetworkIPv4 = cfg.tor.network;
        AutomapHostsOnResolve = true;
        TransPort = [{ addr = cfg.address; port = 9040; }];
      };
      services.dnsmasq.settings = {
        server = [ "/onion/${cfg.address}#9053" ];
        rebind-domain-ok = "onion";
      };
    })
    (mkIf (cfg.enable && cfg.tor.enable && config.networking.nftables.enable) {
      networking.nftables.tables = {
        rkn = {
          family = "ip";
          content = ''
            chain out {
              type nat hook output priority mangle;
              ip protocol tcp ip saddr ${cfg.address} tcp dport { 80, 443 } counter dnat to ${cfg.address}:9040
              ip protocol tcp ip daddr ${cfg.tor.network} tcp dport { 80, 443 } counter dnat to ${cfg.address}:9040
            }
            chain pre {
              type nat hook prerouting priority dstnat;
              ip protocol tcp ip daddr ${cfg.tor.network} tcp dport { 80, 443 } counter dnat to ${cfg.address}:9040
            }
          '';
        };
      };
    })
    (mkIf (cfg.enable && cfg.tor.enable && !config.networking.nftables.enable) {
      networking.firewall.extraCommands = ''
        iptables -t nat -A OUTPUT -p tcp -m multiport --dports 80,443 -s ${cfg.address} -j DNAT --to-destination ${cfg.address}:9040
        # onion
        iptables -t nat -A PREROUTING -p tcp -m multiport --dports 80,443 -d ${cfg.tor.network} -j DNAT --to-destination ${cfg.address}:9040
        iptables -t nat -A OUTPUT -p tcp -m multiport --dports 80,443 -d ${cfg.tor.network} -j DNAT --to-destination ${cfg.address}:9040
      '';
    })
  ];
}
