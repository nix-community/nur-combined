# Just an adblocker
{ config, lib, ... }:

let
  inherit (lib) mkIf;
  cfg = config.abszero.services.xray;

  xraySettings = {
    routing.rules = [
      {
        domain = [ "geosite:category-ads-all" ];
        outboundTag = "block";
      }
      {
        port = 53;
        outboundTag = "dns-out";
      }
    ];

    dns.servers = [
      "fakedns"
      "https://1.1.1.1/dns-query"
      "https://8.8.8.8/dns-query"
    ];

    inbounds = [
      {
        protocol = "dokodemo-door";
        listen = "127.0.0.1";
        port = 1;
        sniffing = {
          enabled = true;
          destOverride = [ "fakedns" ];
        };
        settings = {
          network = "tcp,udp";
          followRedirect = true;
        };
        streamSettings.sockopt.tproxy = "tproxy";
      }
      {
        protocol = "socks";
        listen = "127.0.0.1";
        port = 10808;
        sniffing = {
          enabled = true;
          destOverride = [ "fakedns" ];
        };
        settings.udp = true;
      }
      {
        protocol = "http";
        listen = "127.0.0.1";
        port = 10809;
        sniffing = {
          enabled = true;
          destOverride = [ "fakedns" ];
        };
      }
    ];

    outbounds = [
      {
        tag = "direct";
        protocol = "freedom";
        settings.domainStrategy = "UseIP";
      }
      {
        tag = "block";
        protocol = "blackhole";
      }
      {
        tag = "dns-out";
        protocol = "dns";
      }
    ];
  };

  nftablesRuleset = ''
    table inet xray {
      chain prerouting {
        type filter hook prerouting priority filter; policy accept;
        meta skgid 255 return
        ip daddr { 127.0.0.0/8, 224.0.0.0/4, 255.255.255.255 } return
        meta l4proto tcp ip daddr 192.168.0.0/16 return
        ip daddr 192.168.0.0/16 udp dport != 53 return
        ip6 daddr { ::1, fe80::/10 } return
        meta l4proto tcp ip6 daddr fd00::/8 return
        ip6 daddr fd00::/8 udp dport != 53 return
        meta l4proto { tcp, udp } meta mark set 1 tproxy to :1 accept
      }

      chain output {
        type route hook output priority filter; policy accept;
        meta skgid 255 return
        ip daddr { 127.0.0.0/8, 224.0.0.0/4, 255.255.255.255 } return
        meta l4proto tcp ip daddr 192.168.0.0/16 return
        ip daddr 192.168.0.0/16 udp dport != 53 return
        ip6 daddr { ::1, fe80::/10 } return
        meta l4proto tcp ip6 daddr fd00::/8 return
        ip6 daddr fd00::/8 udp dport != 53 return
        meta l4proto { tcp, udp } meta mark set 1 accept
      }

      chain divert {
        type filter hook prerouting priority mangle; policy accept;
        meta l4proto tcp socket transparent 1 meta mark set 1 accept
      }
    }
  '';
in

mkIf (cfg.enable && cfg.preset == "blackhole-adblock") {
  users = {
    groups.xray.gid = 255;
    users.xray = {
      isSystemUser = true;
      uid = 255;
      group = "xray";
    };
  };

  networking = {
    firewall = {
      allowedTCPPorts = [
        10808
        10809
      ];
      allowedUDPPorts = [
        10808
        10809
      ];
    };

    localCommands = ''
      ip rule add fwmark 1 table 100
      ip route add local 0.0.0.0/0 dev lo table 100

      ip -6 rule add fwmark 1 table 100
      ip -6 route add local ::/0 dev lo table 100
    '';

    nftables = {
      enable = true;
      ruleset = nftablesRuleset;
    };
  };

  services.xray.settings = xraySettings;
}
