devices:

{
  availableKernelModules = [
    "ata_piix" "uhci_hcd" "sd_mod" "sr_mod" "virtio_pci" "virtio_scsi"
    "virtio_mmio" "9p" "9pnet_virtio"
  ];

  kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];

  luks = { inherit devices; };
}
