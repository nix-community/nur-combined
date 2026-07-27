{
  lib,
  inputs,
  system,
  homelab,
  stablePkgs,
  unstablePkgs,
  ...
}:
let
  ipv4NetworkPrefix = "192.168";
  ipv6NetworkPrefix = "fdbd:2025:0518";
  homeVlanId = "10";
  guestVlanId = "20";
  iotVlanId = "30";
in
{
  imports = [
    inputs.nixcfg.modules.nixos.default
    inputs.catppuccin.nixosModules.catppuccin
    inputs.dioxus_monorepo.nixosModules.discord_bot
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.nh.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixos-unstable.nixosModules.notDetected
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
    # inputs.preservation.nixosModules.preservation  # Enable for ephemeral setup
  ];

  # ============================================================================
  # EPHEMERAL SETUP (Optional — requires reinstallation)
  # ============================================================================
  # To switch the Protectli to an impermanent (tmpfs-on-root) setup:
  #
  # 1. Uncomment the preservation module import above.
  # 2. Uncomment the imports below.
  # 3. Remove or comment out `fileSystemPresets.btrfs.enable` below.
  # 4. On the Protectli, run from a NixOS installer:
  #      nix run nixpkgs#disko -- --mode disko ./systems/Protectli/disko.nix
  #      nixos-install --flake .#Protectli
  # 5. Reboot.
  #
  # imports = [
  #   ./disko.nix
  #   ./preservation.nix
  # ];
  # ============================================================================
  home-manager = {
    extraSpecialArgs = {
      inherit
        inputs
        system
        homelab
        stablePkgs
        unstablePkgs
        ;
    };
    sharedModules = [ ./home.nix ];
  };
  catppuccin = {
    enable = true;
    autoEnable = true;
  };
  hardware.cpu.intel.updateMicrocode = true;
  networking = {
    hostName = "Protectli";
    networkmanager.enable = lib.mkForce false;
    domain = "diekvoss.net";
    useNetworkd = true;
    useDHCP = false;
    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
    ];
    nat = {
      enable = true;
      externalInterface = "enp1s0";
      internalInterfaces = [
        "br0"
        "br0.${homeVlanId}"
        "br0.${guestVlanId}"
        "br0.${iotVlanId}"
      ];
    };
    firewall = {
      enable = true;
      # Port 53 is for DNS, 22 is for SSH, 67/68 is for DHCP, 80 is for HTTP, 443 is for HTTPS
      interfaces.enp1s0 = {
        allowedTCPPorts = [
          80
          443
        ];
        allowedUDPPorts = [
          443
        ];
      };
      interfaces.br0 = {
        allowedTCPPorts = [
          53
          22
          80
          443
        ];
        allowedUDPPorts = [
          53
          67
          68
          443
        ];
      };
      interfaces."br0.${homeVlanId}" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [
          53
          67
          68
        ];
      };
      interfaces."br0.${guestVlanId}" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [
          53
          67
          68
        ];
      };
      interfaces."br0.${iotVlanId}" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [
          53
          67
          68
        ];
      };
    };
    nftables.tables.vlan-isolation = {
      family = "inet";
      content = ''
        chain forward {
          type filter hook forward priority filter; policy accept;

          # Allow established/related traffic (enables CDWifi->IoT return traffic)
          ct state established,related accept

          # Allow CDWifi (br0) to initiate connections to IoT (VLAN 30)
          iifname "br0" oifname "br0.${homeVlanId}" accept
          iifname "br0" oifname "br0.${iotVlanId}" accept

          # Guest (VLAN 20): drop all forwarding to private subnets
          iifname "br0.${guestVlanId}" ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } drop
          iifname "br0.${guestVlanId}" ip6 daddr { fc00::/7 } drop

          # IoT (VLAN 30): drop all forwarding to private subnets
          iifname "br0.${iotVlanId}" ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } drop
          iifname "br0.${iotVlanId}" ip6 daddr { fc00::/7 } drop
        }
      '';
    };
  };
  boot = {
    kernel.sysctl = {
      # Prevent IP spoofing
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      # Ignore ICMP redirects
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      # Don't send ICMP redirects
      "net.ipv4.conf.all.send_redirects" = 0;
      # Log martian packets
      "net.ipv4.conf.all.log_martians" = 1;
      # Ignore broadcast pings
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      # SYN flood protection
      "net.ipv4.tcp_syncookies" = 1;
    };
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];
  };
  nixcfg = {
    nix.enable = true;
    security.enable = true;
    home-manager.enable = true;
    networking.enable = true;
    system.enable = true;
    boot.enable = true;
  };
  userPresets.toyvo.enable = true;
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  systemd = {
    network = {
      enable = true;
      networks.wan0 = {
        matchConfig.Name = "enp1s0";
        networkConfig.DHCP = "ipv4";
        dhcpV4Config = {
          UseDNS = false;
        };
        linkConfig.RequiredForOnline = "routable";
      };
      networks.lan0 = {
        matchConfig.Name = "enp2s0 enp3s0 enp4s0";
        networkConfig.Bridge = "br0";
      };
      networks.br0 = {
        matchConfig.Name = "br0";
        address = [
          "${ipv4NetworkPrefix}.0.1/24"
          "${ipv6NetworkPrefix}::1/64"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          MulticastDNS = true;
          IPv6SendRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = [ "${ipv6NetworkPrefix}::1" ];
        };
        ipv6Prefixes = [
          { Prefix = "${ipv6NetworkPrefix}::/64"; }
        ];
        vlan = [
          "br0.${homeVlanId}"
          "br0.${guestVlanId}"
          "br0.${iotVlanId}"
        ];
      };
      networks."br0.${homeVlanId}" = {
        matchConfig.Name = "br0.${homeVlanId}";
        address = [
          "${ipv4NetworkPrefix}.${homeVlanId}.1/24"
          "${ipv6NetworkPrefix}:${homeVlanId}::1/64"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv6SendRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = [ "${ipv6NetworkPrefix}:${homeVlanId}::1" ];
        };
        ipv6Prefixes = [
          { Prefix = "${ipv6NetworkPrefix}:${homeVlanId}::/64"; }
        ];
      };
      networks."br0.${guestVlanId}" = {
        matchConfig.Name = "br0.${guestVlanId}";
        address = [
          "${ipv4NetworkPrefix}.${guestVlanId}.1/24"
          "${ipv6NetworkPrefix}:${guestVlanId}::1/64"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv6SendRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = [ "${ipv6NetworkPrefix}:${guestVlanId}::1" ];
        };
        ipv6Prefixes = [
          { Prefix = "${ipv6NetworkPrefix}:${guestVlanId}::/64"; }
        ];
      };
      networks."br0.${iotVlanId}" = {
        matchConfig.Name = "br0.${iotVlanId}";
        address = [
          "${ipv4NetworkPrefix}.${iotVlanId}.1/24"
          "${ipv6NetworkPrefix}:${iotVlanId}::1/64"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv6SendRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = [ "${ipv6NetworkPrefix}:${iotVlanId}::1" ];
        };
        ipv6Prefixes = [
          { Prefix = "${ipv6NetworkPrefix}:${iotVlanId}::/64"; }
        ];
      };
      netdevs.br0.netdevConfig = {
        Name = "br0";
        Kind = "bridge";
        MACAddress = "none";
      };
      netdevs."br0.${homeVlanId}" = {
        netdevConfig = {
          Name = "br0.${homeVlanId}";
          Kind = "vlan";
        };
        vlanConfig.Id = lib.strings.toInt homeVlanId;
      };
      netdevs."br0.${guestVlanId}" = {
        netdevConfig = {
          Name = "br0.${guestVlanId}";
          Kind = "vlan";
        };
        vlanConfig.Id = lib.string.toInt guestVlanId;
      };
      netdevs."br0.${iotVlanId}" = {
        netdevConfig = {
          Name = "br0.${iotVlanId}";
          Kind = "vlan";
        };
        vlanConfig.Id = lib.strings.toInt iotVlanId;
      };
      links.br0 = {
        matchConfig.OriginalName = "br0";
        linkConfig.MACAddressPolicy = "none";
      };
    };
  };
  services.monitoring.enable = true;
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    kea =
      let
        reserved = 64;
      in
      {
        dhcp4 = {
          enable = true;
          settings = {
            interfaces-config = {
              interfaces = [
                "br0"
                "br0.${homeVlanId}"
                "br0.${guestVlanId}"
                "br0.${iotVlanId}"
              ];
              dhcp-socket-type = "raw";
            };
            lease-database = {
              name = "/var/lib/kea/dhcp4.leases";
              persist = true;
              type = "memfile";
            };
            control-socket = {
              socket-type = "unix";
              socket-name = "/run/kea/kea-dhcp4.socket";
            };
            authoritative = true;
            renew-timer = 3600 * 5;
            rebind-timer = 3600 * 8;
            valid-lifetime = 3600 * 9;
            subnet4 = [
              {
                id = 1;
                pools = [
                  {
                    pool = "${ipv4NetworkPrefix}.0.${toString reserved} - ${ipv4NetworkPrefix}.0.254";
                  }
                ];
                subnet = "${ipv4NetworkPrefix}.0.0/24";
                option-data = [
                  {
                    name = "routers";
                    data = "${ipv4NetworkPrefix}.0.1";
                  }
                ];
              }
              {
                id = lib.strings.toInt homeVlanId;
                pools = [
                  {
                    pool = "${ipv4NetworkPrefix}.${homeVlanId}.${toString reserved} - ${ipv4NetworkPrefix}.${homeVlanId}.254";
                  }
                ];
                subnet = "${ipv4NetworkPrefix}.${homeVlanId}.0/24";
                option-data = [
                  {
                    name = "routers";
                    data = "${ipv4NetworkPrefix}.${homeVlanId}.1";
                  }
                ];
              }
              {
                id = lib.strings.toInt guestVlanId;
                pools = [
                  {
                    pool = "${ipv4NetworkPrefix}.${guestVlanId}.${toString reserved} - ${ipv4NetworkPrefix}.${guestVlanId}.254";
                  }
                ];
                subnet = "${ipv4NetworkPrefix}.${guestVlanId}.0/24";
                option-data = [
                  {
                    name = "routers";
                    data = "${ipv4NetworkPrefix}.${guestVlanId}.1";
                  }
                ];
              }
              {
                id = lib.strings.toInt iotVlanId;
                pools = [
                  {
                    pool = "${ipv4NetworkPrefix}.${iotVlanId}.${toString reserved} - ${ipv4NetworkPrefix}.${iotVlanId}.254";
                  }
                ];
                subnet = "${ipv4NetworkPrefix}.${iotVlanId}.0/24";
                option-data = [
                  {
                    name = "routers";
                    data = "${ipv4NetworkPrefix}.${iotVlanId}.1";
                  }
                ];
              }
            ];
            option-data = [
              {
                name = "domain-name-servers";
                data = "9.9.9.9, 149.112.112.112";
              }
              {
                name = "domain-search";
                data = "diekvoss.internal, diekvoss.net, diekvoss.com";
              }
            ];
            loggers = [
              {
                name = "kea-dhcp4";
                output_options = [
                  {
                    output = "/var/log/kea/kea-dhcp4.log";
                    maxver = 10;
                  }
                ];
                severity = "INFO";
              }
            ];
          };
        };
        dhcp6 = {
          enable = true;
          settings = {
            interfaces-config.interfaces = [
              "br0"
              "br0.${homeVlanId}"
              "br0.${guestVlanId}"
              "br0.${iotVlanId}"
            ];
            lease-database = {
              name = "/var/lib/kea/dhcp6.leases";
              persist = true;
              type = "memfile";
            };
            renew-timer = 3600 * 5;
            rebind-timer = 3600 * 8;
            valid-lifetime = 3600 * 9;
            preferred-lifetime = 3600 * 7;
            subnet6 = [
              {
                id = 1;
                pools = [
                  {
                    pool = "${ipv6NetworkPrefix}::${lib.toHexString reserved} - ${ipv6NetworkPrefix}::ffff";
                  }
                ];
                subnet = "${ipv6NetworkPrefix}::/64";
              }
              {
                id = lib.strings.toInt homeVlanId;
                pools = [
                  {
                    pool = "${ipv6NetworkPrefix}:${homeVlanId}::${lib.toHexString reserved} - ${ipv6NetworkPrefix}:${homeVlanId}::ffff";
                  }
                ];
                subnet = "${ipv6NetworkPrefix}:${homeVlanId}::/64";
              }
              {
                id = lib.strings.toInt guestVlanId;
                pools = [
                  {
                    pool = "${ipv6NetworkPrefix}:${guestVlanId}::${lib.toHexString reserved} - ${ipv6NetworkPrefix}:${guestVlanId}::ffff";
                  }
                ];
                subnet = "${ipv6NetworkPrefix}:${guestVlanId}::/64";
              }
              {
                id = lib.strings.toInt iotVlanId;
                pools = [
                  {
                    pool = "${ipv6NetworkPrefix}:${iotVlanId}::${lib.toHexString reserved} - ${ipv6NetworkPrefix}:${iotVlanId}::ffff";
                  }
                ];
                subnet = "${ipv6NetworkPrefix}:${iotVlanId}::/64";
              }
            ];
            option-data = [
              {
                name = "dns-servers";
                data = "2620:fe::fe, 2620:fe::9";
              }
              {
                name = "domain-search";
                data = "diekvoss.internal, diekvoss.net, diekvoss.com";
              }
            ];
            loggers = [
              {
                name = "kea-dhcp6";
                output_options = [
                  {
                    output = "/var/log/kea/kea-dhcp6.log";
                    maxver = 10;
                  }
                ];
                severity = "INFO";
              }
            ];
          };
        };
      };
  };
}
