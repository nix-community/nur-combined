{ config, lib, ... }:
{

  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
  '';
  networking = {
    domain = "nyaw.xyz";
    firewall = {
      checkReversePath = false;
      enable = true;
      trustedInterfaces = [
        "virbr0"
        "wg0"
        "wg1"
      ];
      allowedUDPPorts = [
        80
        443
        8080
        5173
        23180
        4444
        51820
      ];
      allowedTCPPorts = [
        80
        443
        8080
        9900
        2222
        5173
        8448
      ];
    };

    useNetworkd = true;
    useDHCP = false;

    hostName = "yidhra";
    enableIPv6 = true;

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

  services.resolved = {
    enable = lib.mkForce false;
  };
  systemd.network = {
    enable = true;

    wait-online = {
      enable = true;
      anyInterface = true;
      ignoredInterfaces = [
        "wg0"
        "wg1"
      ];
    };

    links."10-eth0" = {
      matchConfig.MACAddress = "00:16:3e:0c:cd:5d";
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
          PrivateKeyFile = config.vaultix.secrets.wgy.path;
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            PublicKey = "BCbrvvMIoHATydMkZtF8c+CHlCpKUy1NW+aP0GnYfRM=";
            AllowedIPs = [ "10.0.4.2/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "i7Li/BDu5g5+Buy6m6Jnr09Ne7xGI/CcNAbyK9KKbQg=";
            AllowedIPs = [ "10.0.4.3/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "69DTVyNbhMN6/cgLCpcZrh/kGoi1IyxV0QwVjDe5IQk=";
            AllowedIPs = [ "10.0.4.6/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "0wLrznvd32gloUHwgFqv+vlybBtEYQaUOwgqyfa3Fl4=";
            AllowedIPs = [ "10.0.4.4/32" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "49xNnrpNKHAvYCDikO3XhiK94sUaSQ4leoCnTOQjWno=";
            AllowedIPs = [ "10.0.2.0/24" ];
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "jQGcU+BULglJ9pUz/MmgOWhGRjpimogvEudwc8hMR0A=";
            AllowedIPs = [ "10.0.3.0/24" ];
            Endpoint = "172.234.92.148:51820";
            PersistentKeepalive = 15;
          }
          {
            PublicKey = "+fuA9nUmFVKy2Ijfh5xfcnO9tpA/SkIL4ttiWKsxyXI=";
            AllowedIPs = [ "10.0.1.0/24" ];
            Endpoint = "144.126.208.183:51820";
            PersistentKeepalive = 15;
          }
        ];
      };
    };

    networks = {
      "10-wg0" = {
        matchConfig.Name = "wg0";
        address = [
          "10.0.4.1/24"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv4Forwarding = true;
        };

        routes = [
          {
            Destination = "10.0.1.0/24";
            Scope = "link";
          }
          {
            Destination = "10.0.2.0/24";
            Scope = "link";
          }
          {
            Destination = "10.0.3.0/24";
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
