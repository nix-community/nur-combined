{ lib, config, ... }:
{

  imports = [ ./bird.nix ];
  # services.babeld = {
  #   enable = true;
  #   config = ''
  #     skip-kernel-setup true
  #     local-path /var/run/babeld/ro.sock
  #     router-id fa:16:3e:d3:09:f8

  #     interface wg-abhoth type tunnel rtt-min 98 rtt-max 256
  #     interface wg-hastur type tunnel rtt-min 46 rtt-max 256
  #     interface wg-yidhra type tunnel rtt-min 42 rtt-max 256
  #     interface wg-kaambl type tunnel rtt-min 94 rtt-max 256 rtt-decay 68
  #     interface wg-eihort type tunnel rtt-min 40 rtt-max 256

  #     redistribute ip fdcc::/64 ge 64 le 128 local allow
  #     redistribute local deny
  #   '';
  # };

  services.resolved = {
    enable = lib.mkForce false;
    llmnr = "false";
    dnssec = "false";
    extraConfig = ''
      MulticastDNS=off
    '';
    fallbackDns = [ "8.8.8.8#dns.google" ];
    # dnsovertls = "true";
  };
  networking.domain = "nyaw.xyz";
  networking = {
    timeServers = [
      "ntp.sjtu.edu.cn"
      "ntp1.aliyun.com"
      "ntp.ntsc.ac.cn"
      "cn.ntp.org.cn"
    ];
    nameservers = [
      "223.5.5.5#dns.alidns.com"
      "120.53.53.53#dot.pub"
    ];
    resolvconf.useLocalResolver = true;
    firewall = {
      enable = true;
      checkReversePath = false;
      trustedInterfaces = [
        "virbr0"
      ];
      allowedUDPPorts = [
        80
        443
        5173
        8083 # streaming
      ];
      allowedTCPPorts = [
        80
        443
        8083 # streaming
        32193 # stls - ss
      ];
    };

    useNetworkd = true;
    useDHCP = false;

    hostName = "azasos"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    enableIPv6 = true;
    nftables = {

      # interfaces.enp4s0.useDHCP = true;
      #  interfaces.wlp5s0.useDHCP = true;
      #
      # Configure network proxy if necessary
      # proxy.default = "http://127.0.0.1:7890";

      # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      enable = true;

      ruleset = ''
        table ip nat {
        	chain prerouting {
        		type nat hook prerouting priority filter; policy accept;
        		iifname "eth0" udp dport 40000-50000 counter packets 0 bytes 0 dnat to :4432
        	}
        }
        table ip6 nat {
        	chain prerouting {
        		type nat hook prerouting priority filter; policy accept;
        		iifname "eth0" udp dport 40000-50000 counter packets 0 bytes 0 dnat to :4432
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
      matchConfig.MACAddress = "fa:16:3e:d3:09:f8";
      linkConfig.Name = "eth0";
    };

    networks."20-wired" = {
      matchConfig.Name = "eth0";
      DHCP = "yes";
      dhcpV4Config.RouteMetric = 2046;
      dhcpV6Config.RouteMetric = 2046;
      networkConfig = {
        # Bond = "bond1";
        # PrimarySlave = true;
        DNSSEC = true;
        MulticastDNS = true;
        DNSOverTLS = true;
      };
      # # REALLY IMPORTANT
      dhcpV4Config.UseDNS = false;
      dhcpV6Config.UseDNS = false;
    };
  };
}
