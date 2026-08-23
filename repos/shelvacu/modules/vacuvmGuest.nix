{
  modulesPath,
  lib,
  config,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  options = {
    vacuvmGuest.ip = lib.mkOption { type = lib.types.str; };
  };

  config = {
    # virtiofs is the root filesystem; must be in initrd
    boot.initrd.kernelModules = [ "virtiofs" ];
    boot.initrd.availableKernelModules = [ "virtio_pci" ];
    # virtio_console provides /dev/hvc0 — the interactive console the QEMU host
    # exposes as a unix socket (attach with `vacuvm console <name>`).
    boot.kernelModules = [ "virtio_console" ];
    boot.extraModulePackages = [ ];

    # Kernel is provided directly by the QEMU host command; no bootloader needed
    boot.loader.grub.enable = false;

    fileSystems."/" = {
      device = "rootfs"; # must match the virtiofs tag in the QEMU command
      fsType = "virtiofs";
    };

    hardware.enableAllFirmware = false;
    hardware.enableRedistributableFirmware = false;

    # Two consoles: ttyS0 (last = primary /dev/console) is wired to QEMU stdio and
    # captured passively in the host journal; hvc0 is the interactive console on a
    # host unix socket. The kernel logs to both; getty on hvc0 gives login.
    boot.kernelParams = [
      "console=hvc0"
      "console=ttyS0"
    ];
    # /dev/hvc0 appears via the virtio_console module; serial-getty@hvc0 waits on
    # dev-hvc0.device (BindsTo), so this login prompt starts once the device is up.
    systemd.services."serial-getty@hvc0" = {
      enable = true;
      wantedBy = [ "getty.target" ];
    };

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
