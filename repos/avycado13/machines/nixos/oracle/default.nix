{
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    # ./disko.nix
  ];

  # Boot configuration for Oracle Cloud (UEFI)
  # The cloud image ESP is mounted at /boot/efi, not /boot.
  boot.loader.systemd-boot.enable = true;
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xhci_pci"
    "virtio_scsi"
    "virtio_pci"
    "virtio_net"
  ];
  boot.kernelModules = [ "kvm-amd" ];
  # Oracle Cloud ESP is not writable during nixos-rebuild; skip bootloader installation
  boot.tmp.cleanOnBoot = true;

  networking.useDHCP = true;
  users.users.avy.extraGroups = [
    "wheel"
    "docker"
  ];
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];

  system.stateVersion = "26.05";
}
