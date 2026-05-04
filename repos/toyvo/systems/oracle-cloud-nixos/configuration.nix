{
  pkgs,
  config,
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
    inputs.nixcfg.modules.nixos.default
    "${inputs.nixos-unstable}/nixos/modules/profiles/qemu-guest.nix"
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
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_scsi"
    ];
    binfmt.emulatedSystems = [ "x86_64-linux" ];
  };
  home-manager.users.toyvo.programs.beets.enable = lib.mkForce false;
  networking = {
    hostName = "oracle-cloud-nixos";
    firewall = {
      allowedTCPPorts = [
        443
        # gmod
        27015
      ];
      allowedUDPPorts = [
        53
        443
        # gmod
        27015
        27005
      ];
    };
  };
  profiles.defaults.enable = true;
  environment.systemPackages = with pkgs; [
    packwiz
  ];
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    monitoring.enable = true;
    wireguard-tunnel = {
      enable = true;
      role = "peer";
      address = "10.100.0.2/24";
      privateKeySecret = "wireguard-oracle-private-key";
      peerPublicKey = "9EZ8ZiCF34RiMr06QiKBIYGckS9DFUBeX85boFhz2yo=";
      peerEndpoint = "toyvo.dev:51820";
      peerAllowedIPs = [
        "10.100.0.0/24"
        "10.1.0.0/24"
        "10.200.0.0/16"
      ];
    };
    caddy = {
      enable = true;
      email = "collin@diekvoss.com";
      globalConfig = ''
        servers {
          metrics
        }
      '';
      virtualHosts."mc.toyvo.dev" = {
        useACMEHost = "mc.toyvo.dev";
        # Proxy to the terraria container's TShock REST API
        extraConfig = "reverse_proxy http://10.200.1.6:7878";
      };
    };
  };
  security = {
    acme = {
      acceptTerms = true;
      certs."mc.toyvo.dev" = {
        email = "collin@diekvoss.com";
        dnsProvider = "cloudflare";
        credentialFiles = {
          "CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare_w_dns_r_zone_token.path;
        };
      };
    };
    sudo.extraConfig = ''
      %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/nixos-container *
      %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/journalctl *
      %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/systemctl status *
    '';
  };
  containerPresets = {
    minecraft = {
      enable = true;
      natInterface = "enp0s6";
      stateDir = "/var/lib/minecraft";

      settings = {
        declarative = false;
        package = inputs.nixcfg.packages.${system}.papermc-26_1_2;
        jvmOpts = "-Xms10G -Xmx10G -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32";
        lazymc = {
          enable = true;
          config = {
            public = {
              protocol = 775;
              version = "26.1.2";
            };
            rcon.randomize_password = true;
          };
        };
      };
    };
    vintagestory = {
      enable = true;
      natInterface = "enp0s6";
      stateDir = "/var/lib/vintagestory";

    };
    terraria = {
      enable = true;
      natInterface = "enp0s6";
      stateDir = "/var/lib/terraria";
      worldPath = "/var/lib/terraria/world.wld";
      autoCreatedWorldSize = "large";
      maxPlayers = 8;
    };
  };
  sops.secrets = {
    cloudflare_w_dns_r_zone_token = { };
    "discord_bot.env" = { };
    "rclone.conf" = { };
    "wireguard-oracle-private-key" = { };
  };
  users.users.caddy.extraGroups = [ "acme" ];
  userPresets.toyvo.enable = true;
  disko.devices.disk.sda = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          name = "ESP";
          size = "500M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            extraArgs = [
              "-n"
              "BOOT"
            ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [
              "-f"
              "-L"
              "NIXOS"
            ];
            subvolumes = {
              "@" = {
                mountpoint = "/";
              };
              "@home" = {
                mountOptions = [ "compress=zstd" ];
                mountpoint = "/home";
              };
              "@nix" = {
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };
}
