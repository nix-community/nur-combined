{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [];
    kernelModules = [
      "kvm-amd"
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/16a8ee7a-960c-4ab5-a7f9-7b3c642f3e55";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/45C2-8105";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/run/media/ac/hdd" = {
      device = "/dev/disk/by-uuid/68004D20004CF69A";
      fsType = "ntfs-3g";
      options = [
        "auto"
        "nofail"
        "user"
        "exec"
        "uid=1000"
        "gid=100"
        "umask=022"
        "utf8"
      ];
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/55671379-832b-4ccc-af9b-b78f5c029983";}
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
