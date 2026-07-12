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
  internalHosts = lib.pipe homelab [
    (lib.filterAttrs (_: host: host ? ip && lib.hasPrefix "10.1.0." host.ip))
    (lib.mapAttrsToList (
      name: host: {
        inherit name;
        type = "A";
        value = host.ip;
        ttl = "300";
      }
    ))
  ];
  primaryZones = [
    "internal"
    "home.arpa"
  ];
  forwarderZones = [
    {
      zone = "diekvoss.com";
      protocol = "Quic";
      forwarder = "dns.quad9.net:853 (9.9.9.9)";
    }
    {
      zone = "diekvoss.net";
      protocol = "Quic";
      forwarder = "dns.quad9.net:853 (9.9.9.9)";
    }
    {
      zone = "toyvo.dev";
      protocol = "Quic";
      forwarder = "dns.quad9.net:853 (9.9.9.9)";
    }
  ];
  zoneRecords = lib.flatten (
    lib.map (zone: map (host: host // { inherit zone; }) internalHosts) primaryZones
  );
  blocklistUrls = [
    "https://big.oisd.nl/domainswild2"
    "https://nsfw.oisd.nl/domainswild2"
    "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts"
  ];
  forwarders = [
    "dns.quad9.net:853 (9.9.9.9)"
    "dns.quad9.net:853 (149.112.112.112)"
  ];
  # JSON data files for configure-technitium (avoids env var quote mangling)
  zoneRecordsFile = pkgs.writeText "zone-records.json" (builtins.toJSON zoneRecords);
  forwarderZonesFile = pkgs.writeText "forwarder-zones.json" (builtins.toJSON forwarderZones);
  blocklistUrlsFile = pkgs.writeText "blocklist-urls.json" (builtins.toJSON blocklistUrls);
  forwardersFile = pkgs.writeText "forwarders.json" (builtins.toJSON forwarders);
in
{
  imports = [
    inputs.nixcfg.modules.nixos.default
    ./kea.nix
    ./virtual-hosts.nix
    inputs.catppuccin.nixosModules.catppuccin
    inputs.dioxus_monorepo.nixosModules.discord_bot
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.nh.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixos-unstable.nixosModules.notDetected
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
  ];
  catppuccin = {
    enable = true;
    autoEnable = true;
  };
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
    nameservers = [ "127.0.0.1" ];
    # Local /etc/hosts backup for when DNS is down or during bootstrap
    hosts = {
      "127.0.0.1" = [ "localhost" ];
      "::1" = [ "localhost" ];
    }
    // (lib.pipe homelab [
      (lib.filterAttrs (
        _: host: lib.hasPrefix "10.1.0." (host.ip or "") || lib.hasPrefix "10.200." (host.ip or "")
      ))
      (lib.mapAttrsToList (
        name: host:
        lib.nameValuePair host.ip [
          "${name}.diekvoss.net"
          name
        ]
      ))
      lib.listToAttrs
    ]);
    nat = {
      enable = true;
      externalInterface = "enp2s0";
      internalInterfaces = [
        "br0"
        "br0.10"
        "br0.20"
        "br0.30"
        "wg0"
      ];
    };
    wireguard.interfaces.wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets.wireguard-router-private-key.path;
      peers = [
        {
          publicKey = "G78etq+AQlSTd1fOXTpxt+mSB5A+kozeUFfagXz49Ws=";
          allowedIPs = [ "10.100.0.2/32" ];
          persistentKeepalive = 25;
        }
        {
          publicKey = "94cgu2UpmNSwFldrufSwCuUW65dTB0GikxG/HF+JMg4=";
          allowedIPs = [ "10.100.0.3/32" ];
          persistentKeepalive = 25;
        }
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
      interfaces."br0.10" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [
          53
          67
          68
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
          iifname "br0" oifname "br0.10" accept
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
        routes = [
          {
            Destination = "10.200.0.0/16";
            Gateway = "10.1.0.3";
          }
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
          "br0.10"
          "br0.20"
          "br0.30"
        ];
      };
      networks."br0.10" = {
        matchConfig.Name = "br0.10";
        address = [
          "10.1.10.1/24"
          "fdcd:2022:1118:10::1/64"
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
          { Prefix = "fdcd:2022:1118:10::/64"; }
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
      netdevs."br0.10" = {
        netdevConfig = {
          Name = "br0.10";
          Kind = "vlan";
        };
        vlanConfig.Id = 10;
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
    };
    technitium-dns-server = {
      enable = true;
      openFirewall = false;
    };
    # Alloy scrapes local exporters and pushes to Prometheus remote-write
    monitoring = {
      enable = true;
      internet.enable = true;
      alloyExtraConfig = ''
        prometheus.scrape "technitium" {
          targets = [{"__address__" = "localhost:9187"}]
          forward_to = [prometheus.relabel.instance.receiver]
          scrape_interval = "30s"
        }
      '';
      textfileDirectory = "/var/lib/alloy/textfiles";
    };
    caddy = {
      enable = true;
      globalConfig = ''
        servers {
          metrics
        }
      '';
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
  systemd.services.technitium-dns-server.serviceConfig.LogsDirectory = "technitium";
  # Prometheus exporter for Technitium stats + query-log threat scanning
  systemd.services.technitium-exporter = {
    description = "Technitium DNS Prometheus Exporter";
    after = [
      "network.target"
      "technitium-dns-server.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      Environment = [
        "TECHNITIUM_URL=http://127.0.0.1:${toString homelab.${hostName}.services.technitium.port}"
        "EXPORTER_PORT=9187"
        "EXPORTER_ADDR=127.0.0.1"
        "TECHNITIUM_TOKEN_FILE=${config.sops.secrets.technitium_api_key.path}"
        "TECHNITIUM_ADMIN_PASS_FILE=${config.sops.secrets.technitium_admin_password.path}"
      ];
      ExecStart = lib.getExe inputs.nixcfg.packages.${system}.technitium-exporter;
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
  # Periodic network device inventory (ARP + Kea + Technitium clients)
  systemd.services.network-inventory = {
    description = "Collect network device inventory";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
      SupplementaryGroups = [ "systemd-journal" ];
      Environment = [
        "INVENTORY_OUTPUT=/var/lib/alloy/textfiles/network_inventory.prom"
        "KEA_LEASES=/var/lib/kea/dhcp4.leases"
        "TECHNITIUM_URL=http://127.0.0.1:${toString homelab.${hostName}.services.technitium.port}"
        "TECHNITIUM_TOKEN_FILE=${config.sops.secrets.technitium_api_key.path}"
      ];
      ExecStartPre = "+${pkgs.coreutils}/bin/install -d -m 0755 -o root -g root /var/lib/alloy/textfiles";
      ExecStart = lib.getExe inputs.nixcfg.packages.${system}.network-inventory;
    };
  };
  systemd.timers.network-inventory = {
    description = "Periodic network device inventory";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
      Persistent = true;
    };
  };
  # Configure Technitium DNS Server built-in zones, blocklists, and forwarders
  systemd.services.configure-technitium = {
    description = "Configure Technitium DNS Server via API";
    after = [
      "network.target"
      "technitium-dns-server.service"
    ];
    requires = [ "technitium-dns-server.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
      Environment = [
        "TECHNITIUM_URL=http://127.0.0.1:${toString homelab.${hostName}.services.technitium.port}"
        "TECHNITIUM_TOKEN_FILE=${config.sops.secrets.technitium_api_key.path}"
        "TECHNITIUM_ADMIN_PASS_FILE=${config.sops.secrets.technitium_admin_password.path}"
        "TECHNITIUM_ZONE_RECORDS_FILE=${zoneRecordsFile}"
        "TECHNITIUM_FORWARDER_ZONES_FILE=${forwarderZonesFile}"
        "TECHNITIUM_BLOCKLISTS_FILE=${blocklistUrlsFile}"
        "TECHNITIUM_FORWARDERS_FILE=${forwardersFile}"
      ];
      ExecStart = lib.getExe (
        pkgs.writeScriptBin "configure-technitium" ''
          #!${pkgs.python3}/bin/python3
          ${builtins.readFile ./configure-technitium.py}
        ''
      );
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
    technitium_api_key = { };
    technitium_admin_password = { };
  };
}
