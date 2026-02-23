{ ... }:
{
  networking.hostName = "MacBook-Pro-Nixos";
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;
    initrd.availableKernelModules = [
      "usb_storage"
      "sdhci_pci"
    ];
  };
  profiles = {
    defaults.enable = true;
    dev.enable = true;
    gui.enable = true;
  };
  userPresets.toyvo.enable = true;
  fileSystemPresets = {
    boot.enable = true;
    btrfs = {
      enable = true;
      extras.enable = true;
    };
  };
  services.desktopManager.cosmic.enable = true;
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;
}
