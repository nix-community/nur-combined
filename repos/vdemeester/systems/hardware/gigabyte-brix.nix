{ config, pkgs, ... }:

{
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    kernelParams = [
      "kvm_intel.nested=1"
      "intel_iommu=on"
    ];
    loader.efi.canTouchEfiVariables = true;
  };
  hardware = {
    cpu.intel.updateMicrocode = true;
  };
}
