{
  lib,
  pkgs,
  config,
  inputs,
  system,
  homelab,
  stablePkgs,
  unstablePkgs,
  ...
}:
let
  inherit (config.networking) hostName;
in
{
  imports = [
    ../../modules/os/defaults.nix
    ../../modules/os/console.nix
    ../../modules/os/podman.nix
    ../../modules/os/users/toyvo.nix
    ../../modules/nixos/defaults.nix
    ../../modules/nixos/filesystems.nix
    ../../modules/nixos/monitoring/default.nix
    ../../modules/nixos/wireguard/default.nix
    ./kea.nix
    ./virtual-hosts.nix
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
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  networking = {
    hostName = "router";
    networkmanager.enable = lib.mkForce false;
    domain = "diekvoss.net";
    useNetworkd = true;
    useDHCP = false;
    nameservers = [ "127.0.1.53" ];
    nat = {
      enable = true;
      externalInterface = "enp2s0";
      internalInterfaces = [
        "br0"
        "br0.20"
        "br0.30"
        "wg0"
      ];
    };
    firewall = {
      enable = true;
      # Port 53 is for DNS, 22 is for SSH, 67/68 is for DHCP, 80 is for HTTP, 443 is for HTTPS
      interfaces.enp2s0 = {
        allowedTCPPorts = [
          80
          443
        ];
        allowedUDPPorts = [
          443
          51820
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
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "sdhci_pci"
    ];
    kernelModules = [ "kvm-intel" ];
  };
  virtualisation.containers.enable = true;
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  systemd = {
    network = {
      enable = true;
      networks.wan0 = {
        matchConfig.Name = "enp2s0";
        networkConfig.DHCP = "ipv4";
        dhcpV4Config = {
          UseDNS = false;
        };
        linkConfig.RequiredForOnline = "routable";
      };
      networks.lan0 = {
        matchConfig.Name = "enp3s0 enp4s0 enp5s0";
        networkConfig.Bridge = "br0";
      };
      networks.br0 = {
        matchConfig.Name = "br0";
        address = [
          "10.1.0.1/24"
          "fdcd:2022:1118::1/64"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          MulticastDNS = true;
          IPv6SendRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = [ "fdcd:2022:1118::1" ];
        };
        ipv6Prefixes = [
          { Prefix = "fdcd:2022:1118::/64"; }
        ];
        vlan = [
          "br0.20"
          "br0.30"
        ];
      };
      networks."br0.20" = {
        matchConfig.Name = "br0.20";
        address = [
          "10.1.20.1/24"
          "fdcd:2022:1118:20::1/64"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv6SendRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = [ "fdcd:2022:1118::1" ];
        };
        ipv6Prefixes = [
          { Prefix = "fdcd:2022:1118:20::/64"; }
        ];
      };
      networks."br0.30" = {
        matchConfig.Name = "br0.30";
        address = [
          "10.1.30.1/24"
          "fdcd:2022:1118:30::1/64"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv6SendRA = true;
        };
        ipv6SendRAConfig = {
          EmitDNS = true;
          DNS = [ "fdcd:2022:1118::1" ];
        };
        ipv6Prefixes = [
          { Prefix = "fdcd:2022:1118:30::/64"; }
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
    fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "1h";
    };
    openssh = {
      enable = true;
      openFirewall = false;
      settings.PasswordAuthentication = false;
    };
    resolved = {
      enable = true;
      settings.Resolve.DNSStubListenerExtra = "10.1.0.1";
    };
    adguardhome = {
      enable = true;
      port = homelab.${hostName}.services.adguard.port;
      mutableSettings = false;
      settings = {
        user_rules = [
          # Need to allow split.io for my work
          "@@||split.io^"
        ];
        dns = {
          bind_hosts = [ "127.0.1.53" ];
          bootstrap_dns = [ "9.9.9.9" ];
        };
        filters = [
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            name = "AdGuard DNS filter";
            id = 1;
          }
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
            name = "AdAway Default Blocklist";
            id = 2;
          }
          {
            enabled = true;
            url = "https://big.oisd.nl";
            name = "OISD Blocklist Big";
            id = 3;
          }
          {
            enabled = true;
            url = "https://nsfw.oisd.nl";
            name = "OISD Blocklist NSFW";
            id = 4;
          }
        ];
        filtering = {
          filtering_enabled = true;
          rewrites = lib.mapAttrsToList (
            hostname:
            { ip, ... }:
            {
              enabled = true;
              domain = "${lib.toLower hostname}.internal";
              answer = ip;
            }
          ) (lib.filterAttrs (hostname: hostConf: lib.hasAttr "ip" hostConf) homelab);
        };
      };
    };
    caddy = {
      enable = true;
      globalConfig = ''
        servers {
          metrics
        }
      '';
    };
    monitoring.enable = true;
    wireguard-tunnel = {
      enable = true;
      role = "server";
      address = "10.100.0.1/24";
      privateKeySecret = "wireguard-router-private-key";
      peerPublicKey = "G78etq+AQlSTd1fOXTpxt+mSB5A+kozeUFfagXz49Ws=";
      peerAllowedIPs = [ "10.100.0.2/32" ];
    };
    cloudflare-dyndns = {
      enable = true;
      domains = [
        "toyvo.dev"
        "cache.toyvo.dev"
      ];
      proxied = false;
      apiTokenFile = config.sops.secrets.cloudflare_w_dns_r_zone_token.path;
    };
  };
  security.acme =
    let
      cloudflare = {
        email = "collin@diekvoss.com";
        dnsProvider = "cloudflare";
        credentialFiles = {
          "CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare_w_dns_r_zone_token.path;
        };
      };
    in
    {
      acceptTerms = true;
      defaults.email = cloudflare.email;
      certs = {
        "diekvoss.net" = cloudflare // {
          extraDomainNames = [ "*.diekvoss.net" ];
        };
        "toyvo.dev" = cloudflare // {
          extraDomainNames = [ "*.toyvo.dev" ];
        };
      };
    };
  sops.secrets = {
    cloudflare_w_dns_r_zone_token = { };
    "wireguard-router-private-key" = { };
  };
}
