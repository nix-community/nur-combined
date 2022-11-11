{ config, lib, pkgs, ... }:

with lib;

let
  ip4 = pkgs.nur.repos.dukzcry.lib.ip4;
  cfg = config.services.rkn;
  serviceOptions = pkgs.nur.repos.dukzcry.lib.systemd.default // {
    PrivateDevices = true;
    RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
    Group = "dnsmasq";
    StateDirectory = "rkn";
  };
in {
  options.services.rkn = {
    enable = mkEnableOption "Обход блокировок роскомпозора";
    address = mkOption {
      type = types.str;
    };
    OnCalendar = mkOption {
      type = types.str;
      default = "weekly";
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
        };
      };
    default = {};
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.dnsmasq.enable = true;
      services.dnsmasq.extraConfig = ''
        hostsdir=/var/lib/rkn/dnsmasq
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
      systemd.timers.rkn = {
        timerConfig = {
          inherit (cfg) OnCalendar;
        };
        wantedBy = [ "timers.target" ];
      };
      systemd.services.rkn = {
        description = "Сервис выгрузки и обработки списка блокировок роскомпозора";
        path = with pkgs; with pkgs.nur.repos.dukzcry; [ gnugrep coreutils gnused glibc gawk libidn ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "rkn.sh" ''
            set -e
            cd /var/lib/rkn
            ${pkgs.nur.repos.dukzcry.gitupdate}/bin/gitupdate
            # domain column
            cat dump.csv | iconv -f WINDOWS-1251 -t UTF-8 | awk -F ';' '!length($3)' | cut -d ';' -f2 | grep -Eo '^([[:alnum:]]|_|-|\.|\*)+\.[[:alpha:]]([[:alnum:]]|-){1,}' > dump.txt
            # domain from url
            cat dump.csv | iconv -f WINDOWS-1251 -t UTF-8 | cut -d ';' -f3 | grep -Eo '^https?://[[:alnum:]|.]+/?$' | grep -Eo '([[:alnum:]]|_|-|\.|\*)+\.[[:alpha:]]([[:alnum:]]|-){1,}' >> dump.txt
            # remove wildcard
            sed -i 's/^*.//' dump.txt
            mkdir -p /var/lib/rkn/dnsmasq
            cat dump.txt | sort | uniq | idn --no-tld > /var/lib/rkn/dnsmasq/hosts
            sed -i 's#\(.*\)#${cfg.address} \1#' /var/lib/rkn/dnsmasq/hosts
          '';
        } // serviceOptions;
      };
    })
    (mkIf (cfg.enable && cfg.tor.enable) {
      services.tor.enable = true;
      services.tor.client.enable = true;
      services.tor.settings = {
        ExcludeExitNodes = "{RU}";
        # onion
        DNSPort = [{ addr = cfg.address; port = 9053; }];
        VirtualAddrNetworkIPv4 = ip4.networkCIDR cfg.tor.network;
        AutomapHostsOnResolve = true;
        TransPort = [{ addr = cfg.address; port = 9040; }];
        # bridges
        #UseBridges = true;
        #Bridge = "snowflake 192.0.2.3:1";
        #ClientTransportPlugin = ''
        #  snowflake exec ${pkgs.snowflake}/bin/client \
        #    -url https://snowflake-broker.azureedge.net/ \
        #    -front ajax.aspnetcdn.com \
        #    -ice stun:stun.l.google.com:19302 \
        #    -max 3
        #'';
      };
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
