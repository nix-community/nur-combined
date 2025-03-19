{ config, lib, ... }:
{
  imports = [ ./bird.nix ];
  # services.babeld = {
  #   enable = true;
  #   config = ''
  #     skip-kernel-setup true
  #     local-path /var/run/babeld/ro.sock
  #     router-id f2:3c:95:50:a1:73

  #     interface wg-yidhra type tunnel rtt-min 64 rtt-max 256
  #     interface wg-hastur type tunnel rtt-min 165 rtt-max 256
  #     interface wg-azasos type tunnel rtt-min 50 rtt-max 256 rtt-decay 64
  #     interface wg-kaambl type tunnel rtt-min 210 rtt-max 512 rtt-decay 120
  #     interface wg-eihort type tunnel rtt-min 170 rtt-max 384 rtt-decay 60

  #     redistribute ip fdcc::/64 ge 64 le 128 local allow
  #     redistribute local deny
  #   '';
  # };
  services = {
    resolved.enable = lib.mkForce false;
  };
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
  '';
  networking = {
    domain = "nyaw.xyz";
    # resolvconf.useLocalResolver = true;
    firewall = {
      enable = true;
      checkReversePath = false;
      trustedInterfaces = [
        "virbr0"
      ];
      allowedUDPPorts = [
        80
        443
      ];
      allowedTCPPorts = [
        80
        443
        40119 # stls
      ];
    };

    useNetworkd = true;
    useDHCP = false;

    hostName = "abhoth";
    enableIPv6 = true;

    nftables = {
      enable = true;
      # for hysteria port hopping
      ruleset = ''
        define INGRESS_INTERFACE="eth0"
        define PORT_RANGE=20000-50000
        define HYSTERIA_SERVER_PORT=4432

        table inet hysteria_porthopping {
          chain prerouting {
            type nat hook prerouting priority dstnat; policy accept;
            iifname $INGRESS_INTERFACE udp dport $PORT_RANGE counter redirect to :$HYSTERIA_SERVER_PORT
          }
        }
        table ip6 nat {
          chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;
            iifname { hts-yidhra, hts-kaambl } oifname eth0 ip6 saddr fdcc::/16 snat to 2400:8905::f03c:95ff:fe50:a173
          }
        }
      '';
    };
    networkmanager.enable = lib.mkForce false;
    networkmanager.dns = "none";
  };
  systemd.network = {
    enable = true;

    wait-online = {
      enable = true;
      anyInterface = true;
      ignoredInterfaces = [
        "wg0"
      ];
    };

    links."10-eth0" = {
      matchConfig.MACAddress = "f2:3c:95:50:77:31";
      linkConfig.Name = "eth0";
    };

    networks."20-eth0" = {
      matchConfig.Name = "eth0";

      networkConfig = {
        DHCP = "ipv4";
        IPv4Forwarding = true;
        IPv6Forwarding = true;
        IPv6AcceptRA = "yes";
      };
    };

  };
}
