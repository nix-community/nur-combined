{ config
, lib
, ...
}: {
  services = {
    mosdns.enable = true;
    resolved.enable = !config.services.mosdns.enable;
  };
  networking = {
    resolvconf.useLocalResolver = true;
    firewall = {
      checkReversePath = false;
      enable = true;
      trustedInterfaces = [ "virbr0" "wg0" "wg1" ];
      allowedUDPPorts = [ 80 443 8080 5173 23180 4444 51820 3330 8880 ];
      allowedTCPPorts = [ 80 443 8080 9900 2222 5173 8448 3330 8880 ];
    };

    useNetworkd = true;
    useDHCP = false;

    hostName = "abhoth"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    enableIPv6 = true;

    # interfaces.enp4s0.useDHCP = true;
    #  interfaces.wlp5s0.useDHCP = true;
    #
    # Configure network proxy if necessary
    # proxy.default = "http://127.0.0.1:7890";

    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    nftables.enable = true;
    networkmanager.enable = lib.mkForce false;
    networkmanager.dns = "none";

  };
  systemd.network = {
    enable = true;

    wait-online = {
      enable = true;
      anyInterface = true;
      ignoredInterfaces = [ "wg0" "wg1" ];
    };

    links."10-ens5" = {
      matchConfig.MACAddress = "00:16:3e:09:b7:46";
      linkConfig.Name = "ens5";
    };

    netdevs = {

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
              AllowedIPs = [ "10.0.0.2/32" ];
              PersistentKeepalive = 15;
            };
          }
          {
            wireguardPeerConfig = {
              PublicKey = "i7Li/BDu5g5+Buy6m6Jnr09Ne7xGI/CcNAbyK9KKbQg=";
              AllowedIPs = [ "10.0.0.3/32" ];
              PersistentKeepalive = 15;
            };
          }

          {
            wireguardPeerConfig = {
              PublicKey = "PkprQcw4kYLiX1Ix8FcIje1x0yie/gjheX7UbxQ7OUw=";
              AllowedIPs = [ "10.0.0.4/32" ];
              PersistentKeepalive = 15;
            };
          }

          # {
          #   wireguardPeerConfig = {
          #     PublicKey = "+fuA9nUmFVKy2Ijfh5xfcnO9tpA/SkIL4ttiWKsxyXI=";
          #     AllowedIPs = [
          #       "10.0.1.0/24"
          #       "10.0.0.0/24"
          #     ];
          #     Endpoint = "144.126.208.183:51820";
          #     PersistentKeepalive = 15;
          #   };
          # }

          {
            wireguardPeerConfig = {
              PublicKey = "TcqM0iPp4Dw1IceB88qw/hSiPWXAzT9GECVT36eyzgc=";
              AllowedIPs = [ "10.0.0.6/32" ];
              PersistentKeepalive = 15;
            };
          }

          {
            wireguardPeerConfig = {
              PublicKey = "kDWOvV5AJ++zRQeTn12kd9x45JvxNqnwhPnB9HkzK0c=";
              # AllowedIPs = [ "10.0.0.6/32" ];
              PersistentKeepalive = 15;
            };
          }

          {
            wireguardPeerConfig = {
              PublicKey = "83NjKIMSJxSorKEhxbD8lEu0Xa9rbAyGkRD77xsTsWQ=";
              AllowedIPs = [ "10.0.0.15/32" ];
              PersistentKeepalive = 15;
            };
          }
        ];
      };
    };


    networks = {
      "10-wg0" = {
        matchConfig.Name = "wg0";
        address = [
          "10.0.0.5/24"
          "10.0.1.5/24"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPForward = true;
        };
      };

      "20-wired" = {
        matchConfig.Name = "ens5";
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
