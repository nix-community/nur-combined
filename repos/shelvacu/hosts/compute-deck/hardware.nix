{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
    "sdhci_pci"
    "dwc3_pci"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2aad8cab-7b97-47de-8608-fe9f12e211a4";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/boot/EFI" = {
    device = "/dev/disk/by-uuid/C268-79C8";
    fsType = "vfat";
    options = [ "nofail" ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
