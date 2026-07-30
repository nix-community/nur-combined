{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.hardware.hetzner-co-x86-cx23;
in

{
  options.abszero.hardware.hetzner-co-x86-cx23.enable = mkEnableOption ''
    Hetzner Cost-Optimized - x86 - CX23 configuration complementary
    to `inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only`. Due to
    the nixos-hardware module being effective on import, it is not imported by
    this module; you have to import it yourself
  '';

  config = mkIf cfg.enable {
    boot.initrd = {
      availableKernelModules = [
        "ahci"
        "sd_mod"
        "sr_mod"
        "virtio_blk"
        "virtio_mmio"
        "virtio_net"
        "virtio_pci"
        "virtio_scsi"
        "virtiofs"
        "9p"
        "9pnet_virtio"
      ];
      kernelModules = [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
        "virtio_gpu"
      ];
    };

    networking = {
      useDHCP = false; # Static IP
      defaultGateway6 = {
        address = "fe80::1";
        interface = "enp1s0";
      };
    };
  };
}
