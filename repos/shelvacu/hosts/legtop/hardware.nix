{ ... }:
{
  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e3aebf24-be76-4064-a9f5-3930c8cd1382";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/7fd2ca2d-7faf-4d40-8cde-ce531fa679b5";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4C47-D9A3";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
      "nofail"
    ];
  };
  hardware.cpu.intel.updateMicrocode = true;
}
