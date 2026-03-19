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
    inputs.nixcfg.modules.os.defaults
    inputs.nixcfg.modules.os.console
    inputs.nixcfg.modules.os.gui
    inputs.nixcfg.modules.os.podman
    inputs.nixcfg.modules.os.users.toyvo
    inputs.nixcfg.modules.nixos.defaults
    inputs.nixcfg.modules.nixos.filesystems
    inputs.nixcfg.modules.nixos.services.desktopManager.cosmic
    inputs.nixos-hardware.nixosModules.pine64-pinebook-pro
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
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  networking.hostName = "PineBook-Pro";
  boot.loader.systemd-boot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  profiles = {
    defaults.enable = true;
    gui.enable = true;
  };
  userPresets.toyvo.enable = true;
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services.desktopManager.cosmic.enable = true;
}
