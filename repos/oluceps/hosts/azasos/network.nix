{ lib, config, ... }:
{

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
      checkReversePath = false;
      enable = true;
      trustedInterfaces = [
        "virbr0"
        "wg0"
      ];
      allowedUDPPorts = [
        80
        443
        8080
        5173
        23180
        4444
        51820
        8448
        34197
        8083 # streaming
      ];
      allowedTCPPorts = [
        80
        443
        8080
        9900
        2222
        5173
        8448
        32193 # ss
        8083 # streaming
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

    netdevs = {

      wg0 = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.vaultix.secrets.wga.path;
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            PublicKey = "BCbrvvMIoHATydMkZtF8c+CHlCpKUy1NW+aP0GnYfRM=";
            AllowedIPs = [ "10.0.2.2/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "69DTVyNbhMN6/cgLCpcZrh/kGoi1IyxV0QwVjDe5IQk=";
            AllowedIPs = [ "10.0.2.6/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "i7Li/BDu5g5+Buy6m6Jnr09Ne7xGI/CcNAbyK9KKbQg=";
            AllowedIPs = [ "10.0.2.3/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "+fuA9nUmFVKy2Ijfh5xfcnO9tpA/SkIL4ttiWKsxyXI=";
            AllowedIPs = [ "10.0.1.1/24" ];
            Endpoint = "127.0.0.1:41820";
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "jQGcU+BULglJ9pUz/MmgOWhGRjpimogvEudwc8hMR0A=";
            AllowedIPs = [ "10.0.3.1/24" ];
            Endpoint = "127.0.0.1:41821";
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "V3J9d8lUOk4WXj+dIiAZsuKJv3HxUl8J4HvX/s4eElY=";
            AllowedIPs = [ "10.0.4.0/24" ];
            Endpoint = "127.0.0.1:41822";
            PersistentKeepalive = 15;
          }
        ];
      };
    };

    networks = {
      "10-wg0" = {
        matchConfig.Name = "wg0";
        address = [
          "10.0.2.1/24"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv4Forwarding = true;
        };

        routes = [
          {
            Destination = "10.0.3.0/24";
            Scope = "link";
          }
          {
            Destination = "10.0.1.0/24";
            Scope = "link";
          }
          {
            Destination = "10.0.4.0/24";
            Scope = "link";
          }
        ];

      };

      "20-wired" = {
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
  };
}
