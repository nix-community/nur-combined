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
    inputs.nixcfg.modules.os.dev
    inputs.nixcfg.modules.os.podman
    inputs.nixcfg.modules.os.users.toyvo
    inputs.nixcfg.modules.nixos.defaults
    inputs.nixcfg.modules.nixos.filesystems
    inputs.nixcfg.modules.nixos.gaming
    inputs.nixcfg.modules.nixos.services.desktopManager.cosmic
    inputs.jovian.nixosModules.jovian
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
  profiles = {
    defaults.enable = true;
    dev.enable = true;
    gaming.enable = true;
    gui.enable = true;
  };
  userPresets.toyvo.enable = true;
  fileSystemPresets.efi.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services = {
    openssh.enable = true;
    desktopManager.cosmic.enable = true;
    displayManager.cosmic-greeter.enable = lib.mkForce false;
    kanata.enable = lib.mkForce false;
  };
  fileSystems."/mnt/POOL" = {
    device = "/dev/disk/by-label/POOL";
    fsType = "btrfs";
    options = [
      "nofail"
      "noatime"
      "lazytime"
      "compress-force=zstd"
      "space_cache=v2"
      "autodefrag"
      "ssd_spread"
    ];
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
}
