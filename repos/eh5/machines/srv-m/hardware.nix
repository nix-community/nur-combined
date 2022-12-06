{ config, pkgs, lib, ... }: {
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/vda";
  };
  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = 65535;
    "fs.inotify.max_user_watches" = 65535;
  };
  boot.tmpOnTmpfs = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
  };
  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  hardware.enableRedistributableFirmware = true;
}
