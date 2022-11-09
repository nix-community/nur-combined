{ config, pkgs, lib, ... }: {
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/vda";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
  };
  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  hardware.enableRedistributableFirmware = true;
}
