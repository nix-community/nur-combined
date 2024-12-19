{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.rtl88x2bu
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2d701fff-b59c-4484-b7a6-cb7ae1f9eb95";
    fsType = "ext4";
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/a67aebb9-edd0-4d43-ad48-d39c328af47e";
    fsType = "ext4";
  };


  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/7E72-2EFB";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/47983af8-8623-4e46-b9b0-a7abd5e5d9ca";
    }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.open = false;
}
