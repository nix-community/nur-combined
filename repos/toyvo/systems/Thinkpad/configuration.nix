{
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
    ../../modules/os/defaults.nix
    ../../modules/os/console.nix
    ../../modules/os/gui.nix
    ../../modules/os/dev.nix
    ../../modules/os/podman.nix
    ../../modules/os/users/toyvo.nix
    ../../modules/nixos/defaults.nix
    ../../modules/nixos/filesystems.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/services/desktopManager/cosmic.nix
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
  networking.hostName = "Thinkpad";
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    kernelModules = [
      "kvm-amd"
      "amdgpu"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
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
  services.desktopManager.cosmic.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  environment.systemPackages = with pkgs; [
    jetbrains.rider
    jetbrains.rust-rover
  ];
}
