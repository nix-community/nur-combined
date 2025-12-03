{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "mpt3sas"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a4d6a30b-a8b1-460c-9f90-554e61b112fe";
    fsType = "f2fs";
    options = [
      "compress_algorithm=zstd:6"
      "compress_chksum"
      # [246431.843306] F2FS-fs (md127): switch atgc option is not allowed
      # "atgc"
      "gc_merge"
      "usrquota"
      "grpquota"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4F4C-7557";
    fsType = "vfat";
    options = [ "nofail" ];
  };

  swapDevices = [ ];
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
