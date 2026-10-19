{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Reusable Allwinner A64 / Pine64 board profile, in the spirit of
  # nixos-hardware: boot/device-tree/firmware concerns that apply to any
  # Pine64 (sun50i-a64) board, independent of what a given host does with it.

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  hardware.deviceTree = {
    enable = true;

    # Pine64+ (2GB RAM variant), not the base 1GB Pine64.
    name = "allwinner/sun50i-a64-pine64-plus.dtb";

    overlays = [
      {
        name = "pine64-wifi";
        dtsFile = ./dts/pine64-wifi-overlay.dts;
      }
    ];
  };

  # AP6212 (brcmfmac) wifi behind the mmc1 SDIO bus enabled by the
  # pine64-wifi device tree overlay above.
  hardware.enableRedistributableFirmware = lib.mkForce true;

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    kernelParams = [
      "console=ttyS0,115200n8"
      "console=tty0"
    ];
    extraModprobeConfig = ''
      options brcmfmac roamoff=1 pm_config=1
    '';
    swraid.enable = lib.mkForce false;
    supportedFilesystems.zfs = lib.mkForce false;
    zfs.forceImportRoot = lib.mkForce false;
  };

  systemd.services.wifi-powersave-off = {
    description = "Disable WiFi power saving";
    after = [ "sys-subsystem-net-devices-wlan0.device" ];
    bindsTo = [ "sys-subsystem-net-devices-wlan0.device" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.iw}/bin/iw dev wlan0 set power_save off";
    };
  };

  # U-Boot's SPL on Allwinner boards lives at a fixed raw offset before the
  # first partition (8KiB), so it has to be dd'd in after the sd-image is built.
  # No separate firmware partition is needed; extlinux.conf on the root
  # partition is what U-Boot reads to find the kernel.
  sdImage = {
    compressImage = true;
    populateFirmwareCommands = "";
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
    postBuildCommands = ''
      dd if=${pkgs.ubootPine64}/u-boot-sunxi-with-spl.bin of=$img bs=1024 seek=8 conv=notrunc
    '';
  };
}
