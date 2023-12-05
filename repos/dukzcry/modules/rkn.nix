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
      services.dnsmasq.settings = {
        conf-file = "/var/lib/dnsmasq/rkn";
      };
      environment.systemPackages = with pkgs; [ ipset ];
      networking.firewall.extraPackages = with pkgs; [ ipset ];
      networking.firewall.extraCommands = ''
        if ! ipset --quiet list rkn; then
          ipset create rkn hash:ip family inet
        fi
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
        iptables -t nat -A PREROUTING -p tcp -m multiport --dports 80,443 -m set --match-set rkn dst -j DNAT --to-destination ${cfg.address}:9040
        iptables -t nat -A OUTPUT -p tcp -m multiport --dports 80,443 -m set --match-set rkn dst -j DNAT --to-destination ${cfg.address}:9040
        # onion
        iptables -t nat -A PREROUTING -p tcp -m multiport --dports 80,443 -d ${ip4.networkCIDR cfg.tor.network} -j DNAT --to-destination ${cfg.address}:9040
        iptables -t nat -A OUTPUT -p tcp -m multiport --dports 80,443 -d ${ip4.networkCIDR cfg.tor.network} -j DNAT --to-destination ${cfg.address}:9040
      '';
      services.dnsmasq.settings = {
        server = [ "/onion/${cfg.address}#9053" ];
        rebind-domain-ok = "onion";
      };
    })
  ];
}
