{
  inputs,
  config,
  lib,
  ...
}:
{
  services.resolved.enable = lib.mkForce false;
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
  '';
  networking = {
    domain = "nyaw.xyz";
    # resolvconf.useLocalResolver = true;
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
        3330
        8880
        34197 # factorio
        3478 # stun/turn
      ];
      allowedTCPPorts = [
        80
        443
        8080
        8776
        9900
        2222
        5173
        8448
        3330
        8880
      ];
    };

    useNetworkd = true;
    useDHCP = false;

    hostName = "nodens";

    nftables = {
      enable = true;
      # for hysteria port hopping
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
      enable = false;
      anyInterface = true;
      ignoredInterfaces = [
        "wg0"
      ];
    };

    links."10-eth0" = {
      matchConfig.MACAddress = "62:16:bf:7c:57:a3";
      linkConfig.Name = "eth0";
    };
    # links."20-eth1" = {
    #   matchConfig.MACAddress = "22:48:a2:5b:0b:f0";
    #   linkConfig.Name = "eth1";
    # };

    netdevs = {

      wg0 = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.vaultix.secrets.wgn.path;
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            PublicKey = "BCbrvvMIoHATydMkZtF8c+CHlCpKUy1NW+aP0GnYfRM=";
            AllowedIPs = [ "10.0.1.2/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "i7Li/BDu5g5+Buy6m6Jnr09Ne7xGI/CcNAbyK9KKbQg=";
            AllowedIPs = [ "10.0.1.3/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "69DTVyNbhMN6/cgLCpcZrh/kGoi1IyxV0QwVjDe5IQk=";
            AllowedIPs = [ "10.0.1.6/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "0wLrznvd32gloUHwgFqv+vlybBtEYQaUOwgqyfa3Fl4=";
            AllowedIPs = [ "10.0.1.4/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "49xNnrpNKHAvYCDikO3XhiK94sUaSQ4leoCnTOQjWno=";
            AllowedIPs = [ "10.0.2.0/24" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "V3J9d8lUOk4WXj+dIiAZsuKJv3HxUl8J4HvX/s4eElY=";
            AllowedIPs = [ "10.0.4.0/24" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "jQGcU+BULglJ9pUz/MmgOWhGRjpimogvEudwc8hMR0A=";
            AllowedIPs = [ "10.0.3.0/24" ];
            Endpoint = "38.47.119.151:51820";
            PersistentKeepalive = 15;
          }
        ];
      };
    };

    networks = {
      "10-wg0" = {
        matchConfig.Name = "wg0";
        address = [
          "10.0.1.1/24"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv4Forwarding = true;
        };

        routes = [
          {
            Destination = "10.0.2.0/24";
            Scope = "link";
          }
          {
            Destination = "10.0.3.0/24";
            Scope = "link";
          }
          {
            Destination = "10.0.4.0/24";
            Scope = "link";
          }
        ];
      };

      "20-eth0" = {
        matchConfig.Name = "eth0";
        DHCP = "no";
        address =
          [
            "144.126.208.183/20"
          ]
          ++ (map (n: "2604:a880:4:1d0::5b:600${n}/64") (
            (map inputs.ascii2char.asciiToChar ((lib.range 97 102))) ++ (map toString (lib.range 0 9))
          ));

        routes = [
          { Gateway = "144.126.208.1"; }
          {
            Gateway = "2604:a880:4:1d0::1";
            GatewayOnLink = true;
            Scope = "link";
          }
        ];
        # networkConfig = {
        #   DNSSEC = true;
        #   MulticastDNS = true;
        #   DNSOverTLS = true;
        # };
        # # REALLY IMPORTANT
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
      };

      # "30-eth1" = {
      #   matchConfig.Name = "eth1";
      #   address = [
      #     "10.124.0.2/20"
      #     "fe80::2048:a2ff:fe5b:bf0/64"
      #   ];

      #   networkConfig = {
      #     DNSSEC = true;
      #     MulticastDNS = true;
      #     DNSOverTLS = true;
      #   };
      #   # # REALLY IMPORTANT
      #   dhcpV4Config.UseDNS = false;
      #   dhcpV6Config.UseDNS = false;
      # };
    };
  };
}
