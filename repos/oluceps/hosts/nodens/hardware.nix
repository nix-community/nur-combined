{ config, lib, inputs, pkgs, ... }:
{
  boot.loader.grub.device = "/dev/vda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio" ];
  boot.initrd.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];
  boot.kernelParams = [
    "audit=0"
    "net.ifnames=0"

    "console=ttyS0"
    "earlyprintk=ttyS0"
    "rootdelay=300"
  ];

  fileSystems."/" = { device = "/dev/vda1"; fsType = "ext4"; };

  boot.    # inputs.nyx.packages.${pkgs.system}.linuxPackages_cachyos-server-lto;
  kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable)
    ''
      # Set the system time from the hardware clock to work around a
      # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
      # to the *boot time* of the host).
      hwclock -s
    '';


}
