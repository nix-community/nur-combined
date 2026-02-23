{ lib, pkgs, ... }:
{
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  networking.hostName = "rpi4b8b";
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
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
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.sd.enable = true;
  services.openssh.enable = true;
}
