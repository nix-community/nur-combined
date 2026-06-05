# u-boot tuned for Xiaomi Pocophone (untested)
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
  ubootTools,
}:
buildUBoot {
  defconfig = "qcom_defconfig";
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

