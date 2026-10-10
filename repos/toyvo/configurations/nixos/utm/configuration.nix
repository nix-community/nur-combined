{
  ekaPkgs,
  homelab,
  inputs,
  pkgs,
  stablePkgs,
  system,
  unstablePkgs,
  ...
}:
{
  imports = [
    inputs.nixcfg.modules.nixos.default
    "${inputs.nixos-unstable}/nixos/modules/profiles/qemu-guest.nix"
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
  networking.hostName = "utm";
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_pci"
      "usbhid"
      "usb_storage"
      "sr_mod"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
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
  };
  userPresets.toyvo.enable = true;
  services.desktopManager.cosmic.enable = true;
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
