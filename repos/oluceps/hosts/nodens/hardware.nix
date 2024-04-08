{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{

  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
  boot = {
    loader.grub.device = "/dev/vda";
    initrd = {

      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
      systemd.enable = true;
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "xen_blkfront"
        "vmw_pvscsi"
        "virtio_net"
        "virtio_pci"
        "virtio_mmio"
        "virtio_blk"
        "virtio_scsi"
        "9p"
        "9pnet_virtio"
      ];
      kernelModules = [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
      ];

      postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable) ''
        # Set the system time from the hardware clock to work around a
        # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
        # to the *boot time* of the host).
        hwclock -s
      '';
    };
    kernelParams = [
      "audit=0"
      "net.ifnames=0"

      "console=ttyS0"
      "earlyprintk=ttyS0"
      "rootdelay=300"
    ];

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "brutal" ];
    extraModulePackages = with config.boot.kernelPackages; [
      (callPackage "${inputs.self}/pkgs/tcp-brutal.nix" { })
    ];
  };
}
