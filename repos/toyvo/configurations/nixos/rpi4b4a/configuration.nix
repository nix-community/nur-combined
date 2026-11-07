{
  ekaPkgs,
  homelab,
  inputs,
  lib,
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
    inputs.nixcfg.modules.os.toyvo
    inputs.nixcfg.modules.nixos.ids
    inputs.nixcfg.modules.nixos.boot
    inputs.nixcfg.modules.nixos.networking
    inputs.nixcfg.modules.nixos.system
    inputs.nixcfg.modules.nixos.monitoring
    inputs.catppuccin.nixosModules.catppuccin
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixos-unstable.nixosModules.notDetected
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
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
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  networking.hostName = "rpi4b4a";
  boot = {
    loader.grub.enable = false;
    loader.generic-extlinux-compatible = {
      enable = true;
    };
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
  };
  nixcfg = {
    nix.enable = true;
    security.enable = true;
    home-manager.enable = true;
    networking.enable = true;
    system.enable = true;
    boot.enable = true;
  };
  nixcfg.users.toyvo.enable = true;
  services.monitoring.enable = true;
  services.openssh.enable = true;
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
}
