{ lib, ... }:
let
  common = {
    services.resolved.settings.Resolve = {
      LLMNR = "true";
      Cache = "no";
      FallbackDNS = [ "8.8.8.8#dns.google" ];
      DNSSEC = "false";
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
        trustedInterfaces = [
          "virbr0"
          "podman*"
        ];
        allowedUDPPorts = [
          5353
          1901
        ];
        allowedTCPPorts = [
          8080
          1901
        ];
      };
      nftables = {
        enable = true;
      };

      networkmanager.enable = lib.mkForce false;
      networkmanager.dns = "none";
    };

  };
in
{
  flake.modules.nixos."net/hastur" =
    { config, ... }:
    (lib.mkMerge [
      {
        networking = {
          hosts = config.data.hosts.${config.networking.hostName};
          hostName = "hastur"; # Define your hostname.
          firewall = {
            allowedTCPPorts = [
              1901
              21027 # syncthing
            ];
            allowedUDPPorts = [ 1901 ];
          };

          timeServers = [
            "ntp1.aliyun.com"
            "240e:982:13a3:f700:70c6:e4fd:a208:19d3"
            "edu.ntp.org.cn"
            "2001:250:380a:5::10"
          ];
        };

        systemd.network = {
          enable = true;

          wait-online = {
            enable = true;
            anyInterface = true;
            ignoredInterfaces = [
              "wlan0"
              "wg0"
            ];
          };
          links = {
            "10-eno1" = {
              matchConfig.MACAddress = "30:56:0f:58:e1:b3";
              linkConfig.Name = "eno1";
              linkConfig.MTUBytes = "1492";
            };

            "40-wlan0" = {
              matchConfig.MACAddress = "70:66:55:e7:1c:b1";
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
              networkConfig = {
                DNSSEC = true;
              };
            };

            "30-rndis" = {
              matchConfig.Name = "rndis";
              DHCP = "yes";
              networkConfig = {
                DNSSEC = false;
              };
            };
          };
        };
      }
      common
    ]);

  flake.modules.nixos."net/eihort" =
    { config, ... }:
    (lib.mkMerge [
      {
        networking = {
          hosts = config.data.hosts.${config.networking.hostName};
          hostName = "eihort"; # Define your hostname.
          firewall = {
            allowedTCPPorts = [ 21027 ];
            allowedUDPPorts = [ ];
          };
          hostId = "0bc55a2e";

          timeServers = [
            "ntp1.aliyun.com"
            "240e:982:13a3:f700:70c6:e4fd:a208:19d3"
            "edu.ntp.org.cn"
            "2001:250:380a:5::10"
          ];
          nftables = {
            enable = true;
            tables.filter = {
              family = "inet";
              content = ''
                chain forward {
                  type filter hook forward priority filter; policy drop;

                  iifname "eno1" oifname "vm1" accept

                  ct state { established, related } accept
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
      common
    ]);

  flake.modules.nixos."net/abhoth" =
    { ... }:
    lib.mkMerge [
      common
      {
        networking = {
          hostName = "abhoth";
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
              MTUBytes = 1280;
            };
          };
        };

      }
    ];
  flake.modules.nixos."net/yidhra" =
    { ... }:
    lib.mkMerge [
      common
      {
        networking = {
          hostName = "yidhra";
          firewall.allowedUDPPorts = [ 51808 ];
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
            matchConfig.MACAddress = "fa:51:33:18:0a:00";
            linkConfig.Name = "eth0";
          };

          networks."8-eth0" = {
            matchConfig.Name = "eth0";
            networkConfig = {
              DHCP = "ipv4";
              IPv4Forwarding = true;
              IPv6Forwarding = true;
              IPv6AcceptRA = true;
              MulticastDNS = true;
            };

            address = [
              "2404:c140:2005::b:a72a/64"
            ];
            routes = [
              {
                Gateway = "2404:c140:2005::1";
                GatewayOnLink = true;
              }
            ];
            linkConfig.RequiredForOnline = "routable";
          };
        };

      }
    ];
  flake.modules.nixos."net/kaambl" =
    { ... }:
    lib.mkMerge [
      common
      {
        networking = {
          hostName = "kaambl";
        };
        systemd.network = {
          enable = true;

          wait-online = {
            enable = false;
            anyInterface = true;
            ignoredInterfaces = [
              "wlan0"
              "wg0"
            ];
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
              networkConfig = {
                DNSSEC = true;
              };
            };
            "25-ncm" = {
              matchConfig.Name = "ncm";
              DHCP = "yes";
              networkConfig = {
                DNSSEC = true;
              };
            };
          };
        };

      }
    ];
  flake.modules.nixos."net/uubboo" =
    { ... }:
    lib.mkMerge [
      common
      {
        networking = {
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
}
