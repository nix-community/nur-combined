{ inputs, vaculib, ... }:
{
  imports = [
    inputs.jovian.nixosModules.jovian
    inputs.home-manager.nixosModules.default
  ]
  ++ vaculib.directoryGrabberList ./.;

  boot.loader = {
    systemd-boot.enable = false;
    efi = {
      efiSysMountPoint = "/boot/EFI";
      canTouchEfiVariables = false;
    };
    grub = {
      efiSupport = true;
      device = "nodev";
      efiInstallAsRemovable = true;
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  vacu.hostName = "compute-deck";
  vacu.shortHostName = "cd";
  vacu.shell.color = "blue";
  vacu.systemKind = "desktop";
  networking.hostId = "e595d9b0";

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  system.stateVersion = "23.11";

  jovian.devices.steamdeck.enable = true;

  networking.networkmanager.enable = true;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.openssh.enable = true;

  vacu.packages = ''
    jupiter-hw-support
    steamdeck-firmware
    steamdeck-bios-fwupd
  '';
}
