{ pkgs, config, ... }:
{
  fileSystems."/" = { device = "/dev/nvme0n1p1"; fsType = "ext4"; };
  boot = {
    loader.grub.device = "/dev/nvme0n1";

    tmp.cleanOnBoot = true;

    initrd.availableKernelModules = [ "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio" "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
    initrd.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" "nvme" ];

    initrd.postDeviceCommands = pkgs.lib.mkIf (!config.boot.initrd.systemd.enable)
      ''
        # Set the system time from the hardware clock to work around a
        # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
        # to the *boot time* of the host).
        hwclock -s
      '';
  };
}

