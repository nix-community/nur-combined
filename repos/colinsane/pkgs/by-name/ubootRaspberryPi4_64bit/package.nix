# N.B.: this package will likely boot all of these Raspberry Pi variants:
# - rpi 4
# - rpi 400
# - rpi cm4 (Compute Module 4)
# all variants share the same BCM2711 chipset (4x Cortex-A72).
# no other models use that chipset.
#
# this package is probably *not* enough to boot rpi on its own.
# i believe the process is for a rpi-specific firmware file to be placed in /boot,
# which then trampolines into u-boot (this package),
# which then boots the NixOS kernel.
{ buildUBoot }:

(buildUBoot {
  defconfig = "rpi_4_defconfig";
  extraMeta.platforms = [ "aarch64-linux" ];
  extraConfig = ''
    # enable some builtin commands to aid in debugging, while we're here
    CONFIG_CMD_CONFIG=y
    CONFIG_CMD_EFIDEBUG=y
    CONFIG_CMD_GPT=y
    CONFIG_CMD_LOG=y
    CONFIG_CMD_READ=y
    CONFIG_CMD_USB_MASS_STORAGE=y
    CONFIG_LOG_MAX_LEVEL=7
    CONFIG_CMD_LSBLK=y
  '';
  extraMakeFlags = [
    "u-boot.dtb"
    "u-boot.bin"
  ];
  filesToInstall = [ "u-boot.bin" "u-boot.dtb" ];
  postInstall = ''
    mv $out/u-boot.dtb $out/bcm2711-rpi-4-b.dtb
  '';
  extraPatches = [
    # enable booting from > 2 TiB drives
    # ./01-skip-lba-check.patch
    # ./03-verbose-log.patch
  ];
})
