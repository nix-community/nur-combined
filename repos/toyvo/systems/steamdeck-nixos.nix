{ lib, pkgs, ... }:
{
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
