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
    initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
    initrd.kernelModules = [];
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/6a8834bb-d52c-4e19-83db-48cee1cd76fc";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/D73D-7AE6";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    "/srv/storage" = {
      device = "/dev/disk/by-uuid/957f030d-a5e1-4de1-b920-c4de25f51967";
      fsType = "ext4";
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/0af63769-1aa9-4bd9-9a48-34c64ef91626";}
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
