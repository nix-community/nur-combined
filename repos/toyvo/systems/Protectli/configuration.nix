{
  lib,
  inputs,
  system,
  homelab,
  stablePkgs,
  unstablePkgs,
  ...
}:
{
  imports = [
    ../../modules/os/defaults.nix
    ../../modules/os/console.nix
    ../../modules/os/podman.nix
    ../../modules/os/users/toyvo.nix
    ../../modules/nixos/defaults.nix
    ../../modules/nixos/filesystems.nix
    inputs.arion.nixosModules.arion
    inputs.catppuccin.nixosModules.catppuccin
    inputs.dioxus_monorepo.nixosModules.discord_bot
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.nh.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixpkgs-unstable.nixosModules.notDetected
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
  ];
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
        "br0.20"
        "br0.30"
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
      interfaces."br0.20" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [
          53
          67
          68
        ];
      };
      interfaces."br0.30" = {
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
          iifname "br0" oifname "br0.30" accept

          # Guest (VLAN 20): drop all forwarding to private subnets
          iifname "br0.20" ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } drop
          iifname "br0.20" ip6 daddr { fc00::/7 } drop

          # IoT (VLAN 30): drop all forwarding to private subnets
          iifname "br0.30" ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } drop
          iifname "br0.30" ip6 daddr { fc00::/7 } drop
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
  profiles.defaults.enable = true;
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
          "192.168.0.1/24"
          "fdbd:2025:0518::1/64"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          MulticastDNS = true;
          IPv6SendRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = [ "fdbd:2025:0518::1" ];
        };
        ipv6Prefixes = [
          { Prefix = "fdbd:2025:0518::/64"; }
        ];
        vlan = [
          "br0.20"
          "br0.30"
        ];
      };
      networks."br0.20" = {
        matchConfig.Name = "br0.20";
        address = [
          "192.168.20.1/24"
          "fdbd:2025:0518:20::1/64"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv6SendRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = [ "fdbd:2025:0518::1" ];
        };
        ipv6Prefixes = [
          { Prefix = "fdbd:2025:0518:20::/64"; }
        ];
      };
      networks."br0.30" = {
        matchConfig.Name = "br0.30";
        address = [
          "192.168.30.1/24"
          "fdbd:2025:0518:30::1/64"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv6SendRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = [ "fdbd:2025:0518::1" ];
        };
        ipv6Prefixes = [
          { Prefix = "fdbd:2025:0518:30::/64"; }
        ];
      };
      netdevs.br0.netdevConfig = {
        Name = "br0";
        Kind = "bridge";
        MACAddress = "none";
      };
      netdevs."br0.20" = {
        netdevConfig = {
          Name = "br0.20";
          Kind = "vlan";
        };
        vlanConfig.Id = 20;
      };
      netdevs."br0.30" = {
        netdevConfig = {
          Name = "br0.30";
          Kind = "vlan";
        };
        vlanConfig.Id = 30;
      };
      links.br0 = {
        matchConfig.OriginalName = "br0";
        linkConfig.MACAddressPolicy = "none";
      };
    };
  };
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
                "br0.20"
                "br0.30"
              ];
              dhcp-socket-type = "raw";
            };
            lease-database = {
              name = "/var/lib/kea/dhcp4.leases";
              persist = true;
              type = "memfile";
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
                    pool = "192.168.0.${toString reserved} - 192.168.0.254";
                  }
                ];
                subnet = "192.168.0.0/24";
                option-data = [
                  {
                    name = "routers";
                    data = "192.168.0.1";
                  }
                ];
              }
              {
                id = 20;
                pools = [
                  {
                    pool = "192.168.20.${toString reserved} - 192.168.20.254";
                  }
                ];
                subnet = "192.168.20.0/24";
                option-data = [
                  {
                    name = "routers";
                    data = "192.168.20.1";
                  }
                ];
              }
              {
                id = 30;
                pools = [
                  {
                    pool = "192.168.30.${toString reserved} - 192.168.30.254";
                  }
                ];
                subnet = "192.168.30.0/24";
                option-data = [
                  {
                    name = "routers";
                    data = "192.168.30.1";
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
              "br0.20"
              "br0.30"
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
                    pool = "fdbd:2025:0518::${lib.toHexString reserved} - fdbd:2025:0518::ffff";
                  }
                ];
                subnet = "fdbd:2025:0518::/64";
              }
              {
                id = 20;
                pools = [
                  {
                    pool = "fdbd:2025:0518:20::${lib.toHexString reserved} - fdbd:2025:0518:20::ffff";
                  }
                ];
                subnet = "fdbd:2025:0518:20::/64";
              }
              {
                id = 30;
                pools = [
                  {
                    pool = "fdbd:2025:0518:30::${lib.toHexString reserved} - fdbd:2025:0518:30::ffff";
                  }
                ];
                subnet = "fdbd:2025:0518:30::/64";
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
