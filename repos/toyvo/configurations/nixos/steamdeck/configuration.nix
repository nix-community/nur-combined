{
  ekaPkgs,
  homelab,
  inputs,
  lib,
  pkgs,
  stablePkgs,
  system,
  unstablePkgs,
  ...
}:
{
  imports = [
    inputs.nixcfg.modules.os.nix
    inputs.nixcfg.modules.os.security
    inputs.nixcfg.modules.os.home-manager
    inputs.nixcfg.modules.os.console
    inputs.nixcfg.modules.os.gui
    inputs.nixcfg.modules.os.dev
    inputs.nixcfg.modules.os.podman
    inputs.nixcfg.modules.os.toyvo
    inputs.nixcfg.modules.nixos.ids
    inputs.nixcfg.modules.nixos.boot
    inputs.nixcfg.modules.nixos.networking
    inputs.nixcfg.modules.nixos.system
    inputs.nixcfg.modules.nixos.nix-ld
    inputs.nixcfg.modules.nixos.podman
    inputs.nixcfg.modules.nixos.gaming
    inputs.nixcfg.modules.nixos.kanata
    inputs.nixcfg.modules.nixos.cosmic
    inputs.jovian.nixosModules.jovian
    inputs.catppuccin.nixosModules.catppuccin
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
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
        ekaPkgs
        inputs
        system
        homelab
        stablePkgs
        unstablePkgs
        ;
    };
    sharedModules = [ ./home.nix ];
  };
  hardware.cpu.amd.updateMicrocode = true;
  hardware.bluetooth.enable = true;
  networking.hostName = "steamdeck-nixos";
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];
    kernelModules = [ "kvm-amd" ];
  };
  nixcfg = {
    nix.enable = true;
    security.enable = true;
    home-manager.enable = true;
    networking.enable = true;
    system.enable = true;
    boot.enable = true;
    nix-ld.enable = true;
    gui.enable = true;
    dev.enable = true;
    gaming.enable = true;
  };
  nixcfg.users.toyvo.enable = true;
  services = {
    openssh.enable = true;
    desktopManager.cosmic.enable = true;
    displayManager.cosmic-greeter.enable = lib.mkForce false;
    kanata.enable = lib.mkForce false;
  };
  jovian = {
    devices.steamdeck.enable = true;
    steam.enable = true;
    steam.autoStart = true;
    steam.user = "toyvo";
    steam.desktopSession = "cosmic";
  };
  environment.systemPackages = with pkgs; [
    maliit-keyboard
    pwvucontrol
  ];
  disko.devices.disk = {
    nvme0n1 = {
      type = "disk";
      device = "/dev/nvme0n1";
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
                "@var" = {
                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/var";
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
    mmcblk0 = {
      type = "disk";
      device = "/dev/mmcblk0";
      content = {
        type = "gpt";
        partitions = {
          pool = {
            size = "100%";
            content = {
              device = "/dev/disk/by-label/POOL";
              type = "btrfs";
              extraArgs = [
                "-f"
                "-L"
                "POOL"
              ];
              mountpoint = "/mnt/POOL";
              mountOptions = [
                "autodefrag"
                "compress-force=zstd"
                "compress=zstd"
                "lazytime"
                "noatime"
                "nofail"
                "space_cache=v2"
                "ssd_spread"
              ];
            };
          };
        };
      };
    };
  };
}
