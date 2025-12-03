{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.rpi-400;
in
{
  options = {
    sane.hal.rpi-400.enable = lib.mkEnableOption "Raspberry Pi 400 hardware support";
  };
  config = lib.mkIf cfg.enable {
    sane.image.extraBootFiles = [
      # rpi bootrom -> edk2 -> systemd-boot
      # edk2 exists here to provide the base UEFI environment which systemd-boot expects
      pkgs.bootpart-edk2-rpi
    ];

    #v used by systemd-boot
    hardware.deviceTree.name = "broadcom/bcm2711-rpi-400.dtb";

    boot.initrd.availableKernelModules = [
      # TODO: remove as many of these entries as possible, without breaking boot
      # see: <repo:NixOS/nixos-hardware:raspberry-pi/4/default.nix>
      # they ship `usbhid`, `usb_storage`, `vc4`, `pcie_brcmstb`, `reset-raspberrypi`
      "pcie_brcmstb"  #< nixos-hardware says "required for the pcie bus to work"
      # from <https://github.com/reckenrode/nixos-configs/blob/f711febde4bfc54778fe0ab69dc68d2930d50e79/hosts/aarch64-linux/khloe/hardware-configuration.nix#L14>
      # context: <https://discourse.nixos.org/t/how-to-install-a-flake-onto-a-raspberry-pi/18200/7>
      "reset_raspberrypi"  #< nixos-hardware says "required for vl805 firmware to load"
      # "usbhid"  #< nixos default
      "usb_storage"
      "vc4"

      # historical nixos defaults?
      "dm_mod"
      "nvme"
      # "rtc_cmos"
      "sdhci_pci"
      # x86-only?
      "atkbd"
      # "i8042"
      "pcips2"
    ];

    # *hopefully* this fixes boot issues; if rpi ever boots with this removed, then remove it.
    # boot.loader.efi.canTouchEfiVariables = false;

    # boot.kernelPatches = [
    #   {
    #     name = "experimental-fix-sdcard-init-with-systemd-boot";
    #     patch = null;
    #     structuredExtraConfig = with lib.kernel; {
    #       # ACPI = no;  #< TODO: try if still broken
    #       DMI = no;
    #       # EFI = no;  #< TODO: try if still broken
    #       KUNIT = no;  #< not needed if using nixpkgs kernels
    #     };
    #   }
    # ];

    boot.kernelParams = [
      "cma=512M"  #< speculative
    ];

    # XXX(2025-10-16): stock kernel boots to initrd, but appears (?) to fail to mount root:
    # mmc0: invalid bus width
    # mmc0: error -22 whilst initialising SD card
    # linux_rpi4 seems to do the same...
    # boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    # this is true for both `linux-kernel.preferBuiltin = false` and `true`.
    # however, preferBuiltin = true AND `availableKernelModules = ["reset_raspberrypi"]` allows boot to get further;
    # and fail instead by blanking the screen at t=30s (maybe some watchdog feature?)
  };
}
