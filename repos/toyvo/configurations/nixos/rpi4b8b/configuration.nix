{
  lib,
  pkgs,
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
    inputs.catppuccin.nixosModules.catppuccin
    inputs.dioxus_monorepo.nixosModules.discord_bot
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.nh.nixosModules.default
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
  networking.hostName = "rpi4b8b";
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
  userPresets.toyvo.enable = true;
  fileSystemPresets.sd.enable = true;
  services.monitoring.enable = true;
  services.openssh.enable = true;
}
