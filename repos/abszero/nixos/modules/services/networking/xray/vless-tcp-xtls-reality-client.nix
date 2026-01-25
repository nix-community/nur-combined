# State-of-the-art Xray client configuration using VLESS-TCP-XTLS-REALITY
# https://github.com/chika0801/Xray-examples/blob/main/VLESS-XTLS-uTLS-REALITY/config_client.json
{ config, lib, ... }:

let
  inherit (lib) mkIf;
  cfg = config.abszero.services.xray;

  xraySettings = {
    routing = {
      domainStrategy = "IPIfNonMatch";
      rules = [
        {
          inboundTag = [ "api-in" ];
          outboundTag = "api-out";
        }
        {
          port = 53;
          outboundTag = "dns-out";
        }
        # You don't want Network Time Protocol (NTP) servers to return the proxy
        # server's time
        {
          port = 123;
          outboundTag = "direct";
        }
        {
          domain = [ "geosite:category-ads-all" ];
          outboundTag = "block";
        }
        {
          domain = [
            "geosite:tld-cn"
            "geosite:geolocation-cn"
            "geosite:private" # Yes this exists
          ];
          outboundTag = "direct";
        }
        # Proxy is the default, but as IPIfNonMatch is used, we explicitly match
        # non-cn sites to avoid querying their IPs
        {
          domain = [
            "geosite:tld-!cn"
            "geosite:geolocation-!cn"
          ];
          outboundTag = "proxy";
        }
        {
          ip = [
            "geoip:cn"
            "geoip:private"
          ];
          outboundTag = "direct";
        }
      ];
    };

    dns.servers = [
      # Fakedns returns fake IPs and associates them to the requested domain.
      # Then, since sniffing is enabled and destOverride is set to fakedns,
      # Xray inspects all packets and overrides fake IPs with the corresponding
      # domain. Finally, traffic is routed using the domain name.
      {
        address = "fakedns";
        # Prioritize fakedns before the other servers
        domains = [ "geosite:google-cn" ];
      }

      # Since most requests sent to proxy are matched with domain rules, DNS
      # requests are never sent to resolve their domains. The following DNS
      # servers are used to resolve IP for routing and for freedom output.

      # Avoid possible surveillance of google cn
      # https://xtls.github.io/document/level-1/routing-with-dns.html
      {
        address = "https://1.1.1.1/dns-query";
        domains = [ "geosite:google-cn" ];
        skipFallback = true;
        finalQuery = true; # Terminate DNS lookup chain
      }
      # Not sure if DoH does anything as CCP has obviously access to all DNS
      # requests anyway. `+local` sends DNS requests by freedom outbound,
      # bypassing the routing module.
      {
        address = "https+local://223.5.5.5/dns-query"; # Alidns
        expectedIPs = [ "geoip:cn" ];
      }
      # Attempt to request IP optimized for China using EDNS Client Subnet (ECS)
      {
        address = "https://1.1.1.1/dns-query";
        clientIP = "202.96.209.133"; # China Telecom Shanghai DNS server IP
      }
      {
        address = "https://8.8.8.8/dns-query";
        clientIP = "202.96.209.133";
      }
    ];

    inbounds = [
      # Tproxy inbound
      {
        protocol = "dokodemo-door";
        listen = "127.0.0.1";
        port = 1;
        sniffing = {
          enabled = true;
          destOverride = [
            "fakedns"
            "http"
            "tls"
            "quic"
          ];
        };
        settings = {
          network = "tcp,udp";
          followRedirect = true;
        };
        streamSettings.sockopt.tproxy = "tproxy";
      }
      # These two inbounds are only used by other LAN devices
      {
        protocol = "socks";
        listen = "127.0.0.1";
        port = 10808;
        sniffing = {
          enabled = true;
          destOverride = [
            "fakedns"
            "http"
            "tls"
            "quic"
          ];
        };
        settings.udp = true;
      }
      {
        protocol = "http";
        listen = "127.0.0.1";
        port = 10809;
        sniffing = {
          enabled = true;
          destOverride = [
            "fakedns"
            "http"
            "tls"
            "quic"
          ];
        };
      }
      {
        protocol = "tunnel";
        listen = "127.0.0.1";
        port = 8080;
        tag = "api-in";
      }
    ];

    outbounds = [
      {
        tag = "proxy";
        protocol = "vless";
        settings.vnext = [
          {
            inherit (cfg) address;
            port = 443;
            users = [
              {
                id = cfg.clientId;
                flow = "xtls-rprx-vision";
                encryption = "none";
              }
            ];
          }
        ];
        streamSettings = {
          network = "tcp";
          security = "reality";
          realitySettings = {
            fingerprint = "chrome";
            serverName = "pjsekai.sega.jp";
            inherit (cfg.reality) publicKey shortId;
            spiderX = ""; # I don't know what this is
          };
        };
      }
      {
        tag = "direct";
        protocol = "freedom";
        settings.domainStrategy = "UseIP"; # Use Xray's DNS module instead of system DNS
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

    # Enable api server for stats
    api = {
      tag = "api-out";
      services = [ "StatsService" ];
    };

    # Enable stats
    stats = { };

    # Enable traffic stats collection
    policy.system = {
      statsInboundUplink = true;
      statsInboundDownlink = true;
      statsOutboundUplink = true;
      statsOutboundDownlink = true;
    };
  };

  # About tproxy:
  # https://xtls.github.io/Xray-docs-next/document/level-2/transparent_proxy/transparent_proxy.html
  # https://xtls.github.io/Xray-docs-next/document/level-2/tproxy_ipv4_and_ipv6.html
  # These resources are for Xray running on router, but it's mostly the
  # same for client
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

mkIf (cfg.enable && cfg.preset == "vless-tcp-xtls-reality-client") {
  users = {
    # DynamicUser is set to true in the systemd service, so systemd will use
    # the xray user if it is statically defined
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

    # Packets in the output chain cannot use tproxy directly, we need to
    # set their fwmark to 1 and add a rule that sends packets with fwmark=1
    # to lo. They are then matched by the prerouting chain.
    # Currently there's no way to configure ip rules more declaratively
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
