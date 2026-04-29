{
  lib,
  buildUBoot,
  armTrustedFirmwareRK3328,
  rkbin,
}@args:
let
  armTrustedFirmwareRK3328 = args.armTrustedFirmwareRK3328.overrideAttrs (_: {
    NIX_LDFLAGS = "--no-warn-execstack --no-warn-rwx-segments";
    enableParallelBuilding = true;
  });

  preBootCmds = ''
    usb start
    setenv boot_targets usb mmc1
  '';
  bootCmds = ''
    bootflow scan -lb
  '';
in
buildUBoot {
  defconfig = "nanopi-r2s-rk3328_defconfig";
  extraPatches = [
    ./expand-kernel-image-addr-space.patch
  ];
  extraConfig = ''
    CONFIG_ROCKCHIP_EXTERNAL_TPL=y
    CONFIG_EFI_LOADER=n
    CONFIG_BOOTSTD_FULL=y
    CONFIG_USE_PREBOOT=y
    CONFIG_PREBOOT="${lib.replaceStrings [ "\n" ] [ ";" ] preBootCmds}"
    CONFIG_BOOTCOMMAND="${lib.replaceStrings [ "\n" ] [ ";" ] bootCmds}"
    CONFIG_CMD_SAVEENV=y
    CONFIG_CMD_ERASEENV=y
    CONFIG_DM_USB_GADGET=y
    CONFIG_USB_GADGET_DOWNLOAD=y
    CONFIG_USB_FUNCTION_ACM=y
    CONFIG_CONSOLE_MUX=y
  '';
  extraMeta.platforms = [ "aarch64-linux" ];
  env = {
    BL31 = "${armTrustedFirmwareRK3328}/bl31.elf";
    ROCKCHIP_TPL = "${rkbin}/bin/rk33/rk3328_ddr_400MHz_v1.21.bin";
  };
  enableParallelBuilding = true;
  filesToInstall = [
    "u-boot.itb"
    "idbloader.img"
    "u-boot-rockchip.bin"
  ];
}
