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
    inputs.nixcfg.modules.nixos.default
    inputs.catppuccin.nixosModules.catppuccin
    inputs.dioxus_monorepo.nixosModules.discord_bot
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixpkgs-unstable.nixosModules.notDetected
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
  ];

  # Mainline kernel, and the nixos-hardware apple-t2 module is deliberately
  # not imported: its pinned t2linux patchset no longer applies to linux_6_18
  # (4001-asahi-trackpad.patch fails on drivers/hid/hid-magicmouse.c), and a
  # headless Mac Mini doesn't need apple-bce (internal keyboard/trackpad and
  # audio) — USB peripherals use the stock drivers. Re-importing the module
  # would also be required to use hardware.apple-t2.firmware (WiFi/BT
  # firmware; the drivers themselves, brcmfmac/btusb, are mainline).
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
  # Kernel parameters previously contributed by the apple-t2 module,
  # kept so boot behavior is unchanged.
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "pm_async=off"
  ];

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
  hardware.cpu.intel.updateMicrocode = true;
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
