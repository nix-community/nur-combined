{
  lib,
  pkgs,
  config,
  ...
}:
{
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
    };
  };
  boot = {
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
        networkConfig = {
          Address = "192.168.0.1/24";
          IPMasquerade = "ipv4";
          MulticastDNS = true;
        };
      };
      netdevs.br0.netdevConfig = {
        Name = "br0";
        Kind = "bridge";
        MACAddress = "none";
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
