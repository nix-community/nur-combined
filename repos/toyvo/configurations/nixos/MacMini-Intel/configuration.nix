{
  pkgs,
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
    inputs.nixos-hardware.nixosModules.apple-t2
    inputs.catppuccin.nixosModules.catppuccin
    inputs.dioxus_monorepo.nixosModules.discord_bot
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixpkgs-unstable.nixosModules.notDetected
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
  ];

  # Use the mainline kernel instead of the T2-patched one: the pinned
  # t2linux patchset no longer applies to linux_6_18
  # (4001-asahi-trackpad.patch fails on drivers/hid/hid-magicmouse.c), and a
  # headless Mac Mini doesn't need apple-bce (internal keyboard/trackpad and
  # audio) — USB peripherals use the stock drivers. WiFi/Bluetooth firmware
  # still comes from hardware.apple-t2.firmware below.
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

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
  # WiFi/Bluetooth firmware extracted from macOS (kernel-independent files
  # under /lib/firmware/brcm); the drivers (brcmfmac/btusb) are mainline.
  hardware.apple-t2.firmware.enable = true;
  networking = {
    hostName = "MacMini-Intel-NixOS";
  };
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];
  };
  userPresets.toyvo.enable = true;
  nixcfg = {
    nix.enable = true;
    security.enable = true;
    home-manager.enable = true;
    networking.enable = true;
    system.enable = true;
    boot.enable = true;
  };
  catppuccin = {
    enable = true;
    autoEnable = true;
  };
  services.openssh.enable = true;
  environment.systemPackages = with pkgs; [
    signal-cli
  ];
  disko.devices.disk.nvme0n1 = {
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
