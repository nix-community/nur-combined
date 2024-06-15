{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.vpn;
  tor =  cfg.enable && cfg.tor.enable;
  onion = tor && cfg.tor.onion;
in {
  options.services.vpn = {
    enable = mkEnableOption "";
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
          onion = mkEnableOption "";
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
        vpn = {
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
    (mkIf tor {
      services.tor.enable = true;
      services.tor.settings = {
        ExcludeExitNodes = "{RU}";
        TransPort = [{ addr = cfg.address; port = 9040; }];
      };
    })
    (mkIf onion {
      services.tor.settings = {
        DNSPort = [{ addr = cfg.address; port = 9053; }];
        VirtualAddrNetworkIPv4 = cfg.tor.network;
        AutomapHostsOnResolve = true;
      };
    })
    (mkIf (tor && config.networking.nftables.enable) {
      networking.nftables.tables = {
        vpn = {
          family = "ip";
          content = ''
            chain out {
              type nat hook output priority mangle;
              ip protocol tcp ip saddr ${cfg.address} tcp dport { 80, 443 } counter dnat to ${cfg.address}:9040
            }
            ${optionalString onion ''
              chain pre {
                type nat hook prerouting priority dstnat;
                ip protocol tcp ip daddr ${cfg.tor.network} tcp dport { 80, 443 } counter dnat to ${cfg.address}:9040
              }
            ''}
          '';
        };
      };
    })
    (mkIf (tor && !config.networking.nftables.enable) {
      networking.firewall.extraCommands = ''
        iptables -t nat -A OUTPUT -p tcp -m multiport --dports 80,443 -s ${cfg.address} -j DNAT --to-destination ${cfg.address}:9040
        ${optionalString onion ''
          iptables -t nat -A PREROUTING -p tcp -m multiport --dports 80,443 -d ${cfg.tor.network} -j DNAT --to-destination ${cfg.address}:9040
        ''}
      '';
    })
  ];
}
