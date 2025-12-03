{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.gpd-micropc
    ./hardware.nix
    ./bluetooth.nix
  ];

  vacu.hostName = "legtop";
  vacu.shortHostName = "lt";
  vacu.shell.color = "blue";
  vacu.verifySystem.expectedMac = "30:9e:90:33:01:07";
  vacu.systemKind = "laptop";

  system.stateVersion = "24.05";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  services.power-profiles-daemon.enable = true;
  networking.networkmanager.enable = true;

  services.openssh.enable = true;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableAllFirmware = true;

  services.fwupd.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  programs.steam.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_lqx;
  vacu.programs.thunderbird.enable = true;
}
