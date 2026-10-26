{ lib, ... }:
let
  # Every host keeps NetworkManager off, and only the ones that pass
  # `networkmanager = true` set it themselves. Wired stays on
  # systemd-networkd everywhere.
  common =
    {
      networkmanager ? false,
    }:
    {
      services.resolved = {

        settings.Resolve = {
          LLMNR = "true";
          Cache = "no";
          FallbackDNS = [
            "8.8.8.8#dns.google"
            "2001:4860:4860::8888#dns.google"
          ];
          # Off for the links. The home router's DNS returns no DNSSEC
          # signatures, so validation on eno1 or wlan0 fails for most names.
          # Only the sing-box tun0 link turns validation on.
          DNSSEC = "false";
        };
      };
      networking = {
        usePredictableInterfaceNames = true;

        domain = "nyaw.xyz";
        # replicates the default behaviour.
        enableIPv6 = true;
        # WARNING: THIS FAILED MY DHCP
        # interfaces.eth0.wakeOnLan.enable = true;
        # wireless.iwd.enable = true;
        useNetworkd = true;
        useDHCP = false;
        firewall = {
          enable = true;
          checkReversePath = false;
          logRefusedConnections = true;
          trustedInterfaces = [
            "virbr0"
            "podman*"
            "tun0"
          ];
          allowedUDPPorts = [
          ];
          allowedTCPPorts = [
          ];
        };
        nftables = {
          enable = true;
        };

        # services.resolved owns /etc/resolv.conf, so NetworkManager hands its
        # per-link DNS to systemd-resolved instead of writing the file. A
        # default, because the resolved and NetworkManager modules both set
        # their own mode.
        networkmanager.dns = lib.mkDefault "none";
      }
      // lib.optionalAttrs (!networkmanager) {
        networkmanager.enable = lib.mkForce false;
      };
    };
in
{
  flake.modules.nixos."net/hastur" =
    { config, ... }:
    (lib.mkMerge [
      {
        networking = {
          hosts = config.data.hosts.${config.networking.hostName} // {
            "localhost" = [ "alert.nyaw.xyz" ];
          };
          # NetworkManager controls wpa_supplicant over D-Bus.
          networkmanager = {
            enable = true;
            wifi.powersave = false;
            # NetworkManager owns wlan0 and nothing else: eno1, vm2,
            # vxlan-mesh, br0 and the taps stay with systemd-networkd.
            # match-all is explicit because a negative match only implies it
            # when the list holds nothing else, and the owly module adds its
            # own entries to this list.
            unmanaged = [
              "*"
              "except:interface-name:wlan0"
            ];
            # NetworkManager gives Wi-Fi metric 600 by itself, which beats
            # networkd's 1024 on eno1. Keep the wired default route first.
            settings = {
              "connection-wifi-wlan0" = {
                match-device = "interface-name:wlan0";
                "ipv4.route-metric" = 1100;
              };
              # /etc is a read-only overlay on this host, so the profiles go
              # under the state directory, which /persist holds.
              keyfile.path = "/var/lib/NetworkManager/system-connections";
            };
          };
          # /etc is a read-only overlay on this host, so wpa_supplicant must
          # not write its imperative config there. NetworkManager supplies the
          # networks over D-Bus, and a declarative file gives it a start point.
          wireless = {
            allowAuxiliaryImperativeNetworks = false;
            extraConfig = ''
              # NetworkManager adds the networks over D-Bus.
            '';
          };
          hostName = "hastur"; # Define your hostname.
          firewall = {
            allowedTCPPorts = [
              1901
              21027 # syncthing
            ];
            allowedUDPPorts = [ 1901 ];
          };

          nftables = {
            enable = true;
            tables.filter = {
              family = "inet";
              content = ''
                chain forward {
                  type filter hook forward priority filter; policy drop;

                  iifname "eno1" oifname "vm2" accept

                  ct state { established, related } accept

                  iifname "vm2" oifname "vxlan-mesh" icmpv6 type echo-request counter accept
                  iifname "vm2" oifname "vxlan-mesh" ip6 daddr fdcc::3 tcp dport { 5432 } counter accept
                  iifname "vxlan-mesh" oifname "vm2" ct state { established, related } counter accept
                }
                chain postrouting {
                  type nat hook postrouting priority srcnat; policy accept;
                  iifname "vm2" oifname "vxlan-mesh" counter masquerade
                }                
              '';
            };
          };
        };

        systemd.network = {
          enable = true;

          wait-online = {
            enable = true;
            anyInterface = true;
            ignoredInterfaces = [
              "wlan0"
            ];
          };
          links = {
            "10-eno1" = {
              matchConfig.MACAddress = "30:56:0f:58:e1:b3";
              linkConfig.Name = "eno1";
              linkConfig.MTUBytes = "1492";
            };

            "40-wlan0" = {
              matchConfig.MACAddress = "50:ee:32:8e:12:a5";
              linkConfig = {
                Name = "wlan0";
              };
            };
            "30-rndis" = {
              matchConfig.Driver = "rndis_host";
              linkConfig = {
                NamePolicy = "keep";
                Name = "rndis";
                MACAddressPolicy = "persistent";
              };
            };
            "20-ncm" = {
              matchConfig.Driver = "cdc_ncm";
              linkConfig = {
                NamePolicy = "keep";
                Name = "ncm";
                MACAddressPolicy = "persistent";
              };
            };
          };
          networks = {
            "8-eno1" = {
              matchConfig.Name = "eno1";
              networkConfig = {
                DHCP = "ipv4";
                IPv4Forwarding = true;
                IPv6Forwarding = true;
                IPv6AcceptRA = true;
                MulticastDNS = true;
              };
              ipv6AcceptRAConfig = {
                DHCPv6Client = false;
              };

              linkConfig.RequiredForOnline = "routable";
            };

            "25-ncm" = {
              matchConfig.Name = "ncm";
              DHCP = "yes";
            };

            "30-rndis" = {
              matchConfig.Name = "rndis";
              DHCP = "yes";
            };
          };
        };
        # Store both profiles and state outside the read-only /etc overlay.
        preservation.preserveAt."/persist".directories = [
          "/var/lib/NetworkManager"
        ];
        # owlyd reads radio.toml once at startup.
        systemd.services.owlyd.restartTriggers = [
          config.environment.etc."owly/radio.toml".source
        ];
      }
      (common { networkmanager = true; })
    ]);

  flake.modules.nixos."net/eihort" =
    { config, ... }:
    (lib.mkMerge [
      {
        networking = {
          hosts = config.data.hosts.${config.networking.hostName} // {
            "localhost" = [ "alert.nyaw.xyz" ];
          };
          hostName = "eihort"; # Define your hostname.
          firewall = {
            allowedTCPPorts = [
              21027
              443
              3260
            ];
            allowedUDPPorts = [ ];
          };
          hostId = "0bc55a2e";
        };
        systemd.network = {
          enable = true;

          wait-online = {
            enable = true;
            anyInterface = true;
          };

          links."10-eno1" = {
            matchConfig.MACAddress = "ac:1f:6b:e5:fe:3a";
            linkConfig = {
              Name = "eno1";
              WakeOnLan = "magic";
              MTUBytes = "1492";
            };
          };

          links."20-eno2" = {
            matchConfig.MACAddress = "ac:1f:6b:e5:fe:3b";
            linkConfig = {
              Name = "eno2";
              WakeOnLan = "magic";
            };
          };

          networks = {
            "5-eno1" = {
              matchConfig.Name = "eno1";
              networkConfig = {
                DHCP = "ipv4";
                IPv4Forwarding = true;
                IPv6Forwarding = true;
                IPv6AcceptRA = true;
                MulticastDNS = true;
              };
              ipv6AcceptRAConfig = {
                DHCPv6Client = false;
              };
              linkConfig.RequiredForOnline = "routable";
            };
          };
        };
      }
      (common { })
    ]);

  flake.modules.nixos."net/abhoth" =
    { ... }:
    lib.mkMerge [
      (common { })
      {
        networking = {
          hostName = "abhoth";
        };
        services.resolved.dnsDelegates.dn42.Delegate = {
          # configure dn42 anycast servers
          DNS = [
            "fd42:d42:d42:54::1"
            "172.20.0.53"
          ];

          # configure all relevant dn42 domains as route-only domains
          Domains = [
            "~dn42"
            "~20.172.in-addr.arpa"
            "~21.172.in-addr.arpa"
            "~22.172.in-addr.arpa"
            "~23.172.in-addr.arpa"
            "~10.in-addr.arpa"
            "~d.f.ip6.arpa"
          ];
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
            matchConfig.MACAddress = "36:3b:65:1b:7a:0f";
            linkConfig.Name = "eth0";
          };

          networks."8-eth0" = {
            matchConfig.Name = "eth0";
            networkConfig = {
              DHCP = "no";
              IPv4Forwarding = true;
              IPv6Forwarding = true;
              IPv6AcceptRA = true;
            };

            address = [
              "154.31.114.112/24"
            ];

            routes = [
              {
                Gateway = "193.41.250.250";
                GatewayOnLink = true;
              }
            ];
            linkConfig = {
              RequiredForOnline = "routable";
            };
          };
        };

      }
    ];
  flake.modules.nixos."net/nodens" =
    { ... }:
    lib.mkMerge [
      (common { })
      {
        networking = {
          hostName = "nodens";
        };
        services.resolved.dnsDelegates.dn42.Delegate = {
          # configure dn42 anycast servers
          DNS = [
            "fd42:d42:d42:54::1"
            "172.20.0.53"
          ];

          # configure all relevant dn42 domains as route-only domains
          Domains = [
            "~dn42"
            "~20.172.in-addr.arpa"
            "~21.172.in-addr.arpa"
            "~22.172.in-addr.arpa"
            "~23.172.in-addr.arpa"
            "~10.in-addr.arpa"
            "~d.f.ip6.arpa"
          ];
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
            matchConfig.MACAddress = "02:00:17:04:b0:f1";
            linkConfig.Name = "eth0";
          };

          networks."8-eth0" = {
            matchConfig.Name = "eth0";
            networkConfig = {
              DHCP = "yes";
              IPv4Forwarding = true;
              IPv6Forwarding = true;
              IPv6AcceptRA = true;
              MulticastDNS = true;
            };
            ipv6AcceptRAConfig = {
              DHCPv6Client = true;
            };

            linkConfig.RequiredForOnline = "routable";
          };
        };

      }
    ];
  flake.modules.nixos."net/yidhra" =
    { ... }:
    lib.mkMerge [
      (common { })
      {
        networking = {
          hostName = "yidhra";
          firewall.allowedUDPPorts = [ 51808 ];
        };
        services.resolved.dnsDelegates.dn42.Delegate = {
          # configure dn42 anycast servers
          DNS = [
            "fd42:d42:d42:54::1"
            "172.20.0.53"
          ];

          # configure all relevant dn42 domains as route-only domains
          Domains = [
            "~dn42"
            "~20.172.in-addr.arpa"
            "~21.172.in-addr.arpa"
            "~22.172.in-addr.arpa"
            "~23.172.in-addr.arpa"
            "~10.in-addr.arpa"
            "~d.f.ip6.arpa"
          ];
        };
        systemd.network = {
          enable = true;

          wait-online = {
            enable = true;
            anyInterface = true;
            ignoredInterfaces = [
            ];
          };

          links."10-eth0" = {
            matchConfig.MACAddress = "bc:24:11:cd:2f:35";
            linkConfig.Name = "eth0";
          };

          networks."8-eth0" = {
            matchConfig.Name = "eth0";
            networkConfig = {
              DHCP = "no";
              IPv4Forwarding = true;
              IPv6Forwarding = true;
              IPv6AcceptRA = true;
            };

            address = [
              "216.195.195.184/24"
              "2a0f:1cc6:b225:0:c744:d4a4:9364:2971/64"
            ];
            linkConfig.RequiredForOnline = "routable";
            routes = [
              {
                Gateway = "2a0f:1cc6:b225::1";
                GatewayOnLink = true;
              }
              {
                Gateway = "216.195.195.254";
              }
            ];
          };
        };

      }
    ];
  flake.modules.nixos."net/kaambl" =
    { config, ... }:
    lib.mkMerge [
      (common { })
      {
        networking = {
          hostName = "kaambl";
          hosts = config.data.hosts.${config.networking.hostName};
        };
        systemd.network = {
          enable = true;

          wait-online = {
            enable = true;
            anyInterface = true;
          };
          links = {

            "30-rndis" = {
              matchConfig.Driver = "rndis_host";
              linkConfig = {
                NamePolicy = "keep";
                Name = "rndis";
                MACAddressPolicy = "persistent";
              };
            };
            "20-ncm" = {
              matchConfig.Driver = "cdc_ncm";
              linkConfig = {
                NamePolicy = "keep";
                Name = "ncm";
                MACAddressPolicy = "persistent";
              };
            };
            "40-wlan" = {
              matchConfig.Driver = "ath11k_pci";
              linkConfig = {
                Name = "wlan0";
                WakeOnLan = "magic";
              };
            };
          };

          networks = {

            "20-wireless" = {
              matchConfig.Name = "wlan0";
              networkConfig = {
                DHCP = "ipv4";
                IPv4Forwarding = true;
                IPv6Forwarding = true;
                IPv6AcceptRA = true;
                MulticastDNS = true;
              };
              ipv6AcceptRAConfig = {
                DHCPv6Client = false;
                # UseDNS = false;
              };
            };

            "30-rndis" = {
              matchConfig.Name = "rndis";
              DHCP = "yes";
            };
            "25-ncm" = {
              matchConfig.Name = "ncm";
              DHCP = "yes";
            };
          };
        };

      }
    ];
  flake.modules.nixos."net/uubboo" =
    { config, ... }:
    lib.mkMerge [
      (common { })
      {
        networking = {
          hosts = config.data.hosts.${config.networking.hostName} // {
            "localhost" = [ "alert.nyaw.xyz" ];
          };
          hostName = "uubboo";
        };
        systemd.network = {
          enable = true;

          wait-online = {
            enable = true;
            anyInterface = true;
          };
          links."10-eno1" = {
            matchConfig.MACAddress = "c4:09:38:f2:3e:cb";
            linkConfig.Name = "eno1";
          };

          networks."8-eno1" = {
            matchConfig.Name = "eno1";
            networkConfig = {
              DHCP = "yes";
              IPv4Forwarding = true;
              IPv6Forwarding = true;
              IPv6AcceptRA = true;
              MulticastDNS = true;
            };
            ipv6AcceptRAConfig = {
              DHCPv6Client = false;
            };
            linkConfig.RequiredForOnline = "routable";
          };
        };
      }
    ];
  flake.modules.nixos."net/azasos" =
    { config, ... }:
    lib.mkMerge [
      (common { })
      {
        vaultix.secrets.wg-azasos-warp = {
          owner = "systemd-network";
          group = "root";
          mode = "400";
        };
        networking = {
          hosts = config.data.hosts.${config.networking.hostName} // {
            "localhost" = [ "alert.nyaw.xyz" ];
          };
          hostName = "azasos";
          firewall.allowedUDPPorts = [ 46292 ];
        };

        systemd.network = {
          enable = true;
          wait-online = {
            enable = true;
            anyInterface = true;
          };
          links."10-eth0" = {
            matchConfig.MACAddress = "bc:24:11:21:c7:2c";
            linkConfig.Name = "eth0";
          };
          netdevs."20-warp" = {
            netdevConfig = {
              Name = "warp";
              Kind = "wireguard";
              MTUBytes = 1280;
            };
            wireguardConfig = {
              PrivateKeyFile = config.vaultix.secrets.wg-azasos-warp.path;
              # Keep the source port that passes the handshake on this network.
              ListenPort = 46292;
            };
            wireguardPeers = [
              {
                PublicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
                # Use IPv6 for the outer tunnel on this IPv6-only host.
                # UDP 2408 gets no replies on this host. Use the WARP fallback port.
                Endpoint = "[2606:4700:d0::a29f:c001]:1701";
                AllowedIPs = [ "0.0.0.0/0" ];
                PersistentKeepalive = 25;
              }
            ];
          };
          networks."20-warp" = {
            matchConfig.Name = "warp";
            address = [ "172.16.0.2/32" ];
            networkConfig = {
              DHCP = "no";
              LinkLocalAddressing = "no";
              IPv6AcceptRA = false;
              # Preserve native IPv6 routing and the existing DNS configuration.
              DNSDefaultRoute = false;
            };
            routes = [
              {
                Destination = "0.0.0.0/0";
                Metric = 1024;
                PreferredSource = "172.16.0.2";
              }
            ];
            linkConfig.RequiredForOnline = false;
          };
          networks."8-eth0" = {
            matchConfig.Name = "eth0";
            networkConfig = {
              DHCP = "no";
              IPv4Forwarding = true;
              IPv6Forwarding = true;
              IPv6AcceptRA = true;
              MulticastDNS = true;
            };
            ipv6AcceptRAConfig = {
              DHCPv6Client = false;
            };
            address = [ "2401:b60:e0fe:3e::2/64" ];
            routes = [ { Gateway = "2401:b60:e0fe:3e::1"; } ];
            linkConfig.RequiredForOnline = "routable";
          };
        };
      }
    ];
}
