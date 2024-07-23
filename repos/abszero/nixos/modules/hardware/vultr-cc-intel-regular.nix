{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.hardware.vultr-cc-intel-regular;
in

{
  imports = [ ../../../lib/modules/config/abszero.nix ];

  options.abszero.hardware.vultr-cc-intel-regular.enable = mkExternalEnableOption config ''
    Vultr Cloud Compute - Intel - Regular Performance configuration complementary
    to `inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only`. Due to
    the nixos-hardware module being effective on import, it is not imported by
    this module; you have to import it yourself.
  '';

  config = mkIf cfg.enable {
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    boot.initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "sr_mod"
      "virtio_blk"
    ];

    virtualisation.hypervGuest.enable = true;
  };
}
