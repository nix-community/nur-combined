{ modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # virtiofs is the root filesystem; must be in initrd
  boot.initrd.kernelModules = [ "virtiofs" ];
  boot.initrd.availableKernelModules = [ "virtio_pci" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Kernel is provided directly by the QEMU host command; no bootloader needed
  boot.loader.grub.enable = false;

  fileSystems."/" = {
    device = "rootfs"; # must match the virtiofs tag in the QEMU command
    fsType = "virtiofs";
  };

  hardware.enableAllFirmware = false;
  hardware.enableRedistributableFirmware = false;

  boot.kernelParams = [ "console=ttyS0" ];
}
