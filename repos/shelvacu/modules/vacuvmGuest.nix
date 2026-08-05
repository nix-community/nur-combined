{ modulesPath, lib, config, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  options = {
    vacuvmGuest.ip = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    # virtiofs is the root filesystem; must be in initrd
    boot.initrd.kernelModules = [ "virtiofs" ];
    boot.initrd.availableKernelModules = [ "virtio_pci" ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    # Kernel is provided directly by the QEMU host command; no bootloader needed
    boot.loader.grub.enable = false;

    fileSystems."/" = {
      device = "rootfs"; # must match the virtiofs tag in the QEMU command
      fsType = "virtiofs";
    };

    hardware.enableAllFirmware = false;
    hardware.enableRedistributableFirmware = false;

    boot.kernelParams = [ "console=ttyS0" ];

    vacu.systemKind = lib.mkDefault "minimal";

    networking.useNetworkd = true;
    systemd.network.enable = true;
    # Match any ethernet interface (there is exactly one: the virtio-net NIC)
    systemd.network.networks."10-eth" = {
      matchConfig.Type = "ether";
      networkConfig = {
        DHCP = "no";
        Address = "${config.vacuvmGuest.ip}/24";
        Gateway = "10.78.77.1";
        DNS = "10.78.79.1";
      };
    };

    services.openssh.enable = lib.mkDefault true;
  };
}
