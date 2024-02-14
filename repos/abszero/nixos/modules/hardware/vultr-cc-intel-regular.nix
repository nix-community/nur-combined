# Cloud Compute - Intel - Regular Performance
{ inputs, lib, ... }: {
  imports = [ inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];

  virtualisation.hypervGuest.enable = true;
}
