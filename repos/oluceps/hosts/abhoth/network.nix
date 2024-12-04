{ config, lib, ... }:
{
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
        34197 # factorio realm
      ];
      allowedTCPPorts = [
        80
        443
        8080
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

    hostName = "abhoth";
    enableIPv6 = false;

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

    netdevs = {
      wg0 = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.vaultix.secrets.wgab.path;
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            PublicKey = "BCbrvvMIoHATydMkZtF8c+CHlCpKUy1NW+aP0GnYfRM=";
            AllowedIPs = [ "10.0.3.2/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "i7Li/BDu5g5+Buy6m6Jnr09Ne7xGI/CcNAbyK9KKbQg=";
            AllowedIPs = [ "10.0.3.3/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "69DTVyNbhMN6/cgLCpcZrh/kGoi1IyxV0QwVjDe5IQk=";
            AllowedIPs = [ "10.0.3.6/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "+fuA9nUmFVKy2Ijfh5xfcnO9tpA/SkIL4ttiWKsxyXI=";
            AllowedIPs = [ "10.0.1.1/24" ];
            Endpoint = "144.126.208.183:51820";
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "V3J9d8lUOk4WXj+dIiAZsuKJv3HxUl8J4HvX/s4eElY=";
            AllowedIPs = [ "10.0.4.0/24" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "49xNnrpNKHAvYCDikO3XhiK94sUaSQ4leoCnTOQjWno=";
            AllowedIPs = [ "10.0.2.1/24" ];
            PersistentKeepalive = 15;
          }
        ];
      };
    };

    networks = {
      "10-wg0" = {
        matchConfig.Name = "wg0";
        address = [
          "10.0.3.1/24"
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
            Destination = "10.0.1.0/24";
            Scope = "link";
          }
        ];
      };
      "20-eth0" = {
        matchConfig.Name = "eth0";
        DHCP = "yes";
      };
    };
  };
}
