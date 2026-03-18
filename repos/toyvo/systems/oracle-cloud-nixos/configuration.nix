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
    ../../modules/os/defaults.nix
    ../../modules/os/console.nix
    ../../modules/os/podman.nix
    ../../modules/os/users/toyvo.nix
    ../../modules/nixos/defaults.nix
    ../../modules/nixos/monitoring/default.nix
    ../../modules/nixos/services/minecraft.nix
    ../../modules/nixos/wireguard/default.nix
    ../../modules/nixos/containers/podman.nix
    ../../modules/nixos/containers/portainer.nix
    ../../modules/nixos/vintagestory.nix
    "${inputs.nixpkgs-unstable}/nixos/modules/profiles/qemu-guest.nix"
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
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_scsi"
    ];
    binfmt.emulatedSystems = [ "x86_64-linux" ];
  };
  containerPresets = {
    podman.enable = true;
  };
  home-manager.users.toyvo.programs.beets.enable = lib.mkForce false;
  networking = {
    hostName = "oracle-cloud-nixos";
    firewall = {
      allowedTCPPorts = [
        443
        # gmod
        27015
        # minecraft java
        25565
        25566
        # terraria
        7777
      ];
      allowedUDPPorts = [
        53
        443
        # gmod
        27015
        27005
        # minecraft bedrock
        19132
        # mincraft voice mod
        24454
        # terraria
        7777
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
        extraConfig = "reverse_proxy http://0.0.0.0:7878";
      };
    };
    minecraft-server = {
      declarative = false;
      enable = true;
      eula = true;
      lazymc = {
        enable = true;
        config = {
          public = {
            protocol = 774;
            version = "1.21.11";
          };
          rcon.randomize_password = true;
        };
      };
      openFirewall = true;
      package = pkgs.papermcServers.papermc-1_21_11;
      jvmOpts = "-Xms10G -Xmx10G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
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
  };
  vintagestory = {
    enable = true;
    openFirewall = true;
  };
  containerPresets.portainer = {
    enable = true;
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
