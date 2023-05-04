{ buildUBoot, fetchurl }:

(buildUBoot {
  # nixos-22.05 is on 2022.01 at time of writing, which lacks rpi-4 dtb.
  # TODO: remove this version/src override once upstream bumps u-boot version.
  version = "2022.04";
  src = fetchurl {
    url = "ftp://ftp.denx.de/pub/u-boot/u-boot-2022.04.tar.bz2";
    hash = "sha256-aOBlQTkmd44nbsOr0ouzL6gquqSmiY1XDB9I+9sIvNA=";
  };
  defconfig = "rpi_4_defconfig";
  extraMeta.platforms = [ "aarch64-linux" ];
  extraConfig = ''
    # TODO: this can be removed in 2022.04
    CONFIG_DEFAULT_DEVICE_TREE="bcm2711-rpi-4-b"
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
    ./01-skip-lba-check.patch
    # ./03-verbose-log.patch
  ];
})
