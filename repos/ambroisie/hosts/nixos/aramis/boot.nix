{ ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [
        "nvme"
        "sd_mod"
        "sdhci_pci"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = [
        "dm-snapshot"
      ];
      luks.devices.crypt = {
        device = "/dev/nvme0n1p1";
        preLVM = true;
      };
    };

    kernelModules = [
      "kvm-intel"
    ];
    extraModulePackages = [ ];
  };
}
