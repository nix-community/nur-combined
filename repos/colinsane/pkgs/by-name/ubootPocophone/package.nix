# u-boot tuned for Xiaomi Pocophone
# references:
# - <https://github.com/MatthewCroughan/nixos-sdm845/blob/master/oneplus-enchilada/sdm845-uboot.nix>
# - <https://github.com/MatthewCroughan/nixos-sdm845/blob/master/oneplus-fajita/sdm845-uboot.nix>
{
  buildUBoot,
  bison,
  flex,
  gnutls,
  openssl,
  xxd,
}:
buildUBoot {
  # `qcom-phone.config` adds `CONFIG_PANIC_HANG` (evidence that u-boot actually launched!),
  # enables `fastboot oem console` (for log viewing). documented in doc/board/qualcomm/phones.rst.
  # `qcom-phone.config` is supposed to be convenience but somehow it's actually load bearing in my boot process.
  defconfig = "qcom_defconfig qcom-phone.config";
  # `bootflow scan -lb` is something of a "standard" boot process;
  # qcom's default `bootefi bootmgr` would skip SD card and extlinux.conf-based boot.
  prePatch = ''
    substituteInPlace board/qualcomm/qcom-phone.env \
      --replace-fail 'bootcmd=bootefi bootmgr;' 'bootcmd=bootflow scan -lb;'
  '';
  filesToInstall = [
    "u-boot"  #< ELF file
    "u-boot-dtb.bin"
    "u-boot-nodtb.bin"
    "u-boot.bin"
    "u-boot.cfg"  #< copy of Kconfig which this u-boot was compiled with
    "u-boot.dtb"
    # "dts/upstream/src/arm64/qcom/sdm845-xiaomi-beryllium-tianma.dtb"  # same as u-boot.dtb
  ];
  extraMakeFlags = [
    "DEVICE_TREE=qcom/sdm845-xiaomi-beryllium-tianma"
  ];
  # extraConfig = ''
  #   # default BOOTDELAY is 1; raise temporarily for debugging
  #   CONFIG_BOOTDELAY=5
  #   CONFIG_WATCHDOG=n

  #   CONFIG_BAUDRATE=115200
  #   CONFIG_DEBUG_UART=y
  #   CONFIG_DEBUG_UART_ANNOUNCE=y
  #   CONFIG_DEBUG_UART_BASE=0xa84000
  #   CONFIG_DEBUG_UART_MSM_GENI=y
  #   CONFIG_DEBUG_UART_CLOCK=7372800
  # '';
  # trying to trim down the deps and especially openssl stuff, but didn't seem to take effect
  # extraConfig = ''
  #   CONFIG_BOOTMETH_EXTLINUX_PXE=n
  #   CONFIG_CMD_PXE=n
  #   CONFIG_FIT=n
  #   CONFIG_FIT_SIGNATURE=n
  #   CONFIG_FIT_VERBOSE=n
  #   CONFIG_SPL_FIT_SIGNATURE=n
  #   CONFIG_TOOLS_FIT_SIGNATURE=n
  # '';
  nativeBuildInputs = [
    # these seem to be required because it needs to compile the dts?
    # it's unclear to me why providing `ubootTools` as input isn't enough for this though.
    bison
    flex
    gnutls
    # ubootTools
    xxd
    openssl
  ];
  extraMeta.platforms = [ "aarch64-linux" ];
}
