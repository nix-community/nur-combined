{ lib, config, ... }:
{
  networking = {
    domain = "nyaw.xyz";
    resolvconf.useLocalResolver = true;
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
        1935
        1985
        10080
        8000
      ];
      allowedTCPPorts = [
        80
        443
        8080
        9900
        2222
        5173
        8448
        1935
        1985
        10080
        8000
      ];
    };

    useNetworkd = true;
    useDHCP = false;

    hostName = "colour";
    enableIPv6 = true;
    nftables = {
      enable = true;
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
        "wg1"
      ];
    };

    links."eth0" = {
      matchConfig.MACAddress = "00:22:48:67:8d:4a";
      linkConfig.Name = "eth0";
    };

    netdevs = {
      wg2 = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg2";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.wgc-warp.path;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
              Endpoint = "162.159.192.1:2408";
              AllowedIPs = [ "::/0" ];
              PersistentKeepalive = 15;
            };
          }
        ];
      };
      wg0 = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.wga.path;
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "BCbrvvMIoHATydMkZtF8c+CHlCpKUy1NW+aP0GnYfRM=";
              AllowedIPs = [
                "10.0.1.2/32"
                "192.168.1.0/24"
              ];
              PersistentKeepalive = 15;
            };
          }
          {
            wireguardPeerConfig = {
              PublicKey = "i7Li/BDu5g5+Buy6m6Jnr09Ne7xGI/CcNAbyK9KKbQg=";
              AllowedIPs = [
                "10.0.1.3/32"
                "10.234.0.0/24"
              ];
              PersistentKeepalive = 15;
            };
          }

          {
            wireguardPeerConfig = {
              PublicKey = "PkprQcw4kYLiX1Ix8FcIje1x0yie/gjheX7UbxQ7OUw=";
              AllowedIPs = [ "10.0.1.4/32" ];
              PersistentKeepalive = 15;
            };
          }
          {
            wireguardPeerConfig = {
              PublicKey = "+fuA9nUmFVKy2Ijfh5xfcnO9tpA/SkIL4ttiWKsxyXI=";
              AllowedIPs = [ "10.0.1.1/32" ];
              Endpoint = "144.126.208.183:51820";
              PersistentKeepalive = 15;
            };
          }
        ];
      };
    };

    networks = {

      "10-wg0" = {
        matchConfig.Name = "wg0";
        address = [ "10.0.1.9/24" ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPForward = true;
        };
      };
      "15-wg2" = {

        matchConfig.Name = "wg2";
        address = [
          # "172.16.0.2/32"
          "2606:4700:110:82bf:db9a:4a73:b4e3:5b57/128"
        ];
        networkConfig = {
          IPMasquerade = "ipv6";
          IPForward = true;
        };

        routes = [
          {
            routeConfig = {
              Destination = "::/0";
              Gateway = "fe80::1";
              Scope = "link";
            };
          }
        ];
      };

      "20-wired" = {
        matchConfig.Name = "eth0";
        DHCP = "yes";
        # address = [
        #   "10.0.0.10"
        # ];

        # routes = [
        #   { routeConfig.Gateway = "10.0.0.1"; }
        # ];
      };
    };
  };
}
