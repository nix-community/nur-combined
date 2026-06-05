{ buildUBoot }:
buildUBoot {
  defconfig = "snow_defconfig";
  extraMeta.platforms = [ "armv7l-linux" ];
  filesToInstall = [
    "u-boot"  #< ELF file
    "u-boot.bin"  #< raw binary, load it into RAM and jump to it
    "u-boot.cfg"  #< copy of Kconfig which this u-boot was compiled with
    "u-boot.dtb"
    "u-boot.map"
    "u-boot-nodtb.bin"
    "u-boot.sym"
  ];
  # CONFIG_BOOTCOMMAND: autoboot from usb, and fix the ordering so that it happens before the internal memory (mmc0)
  extraConfig = ''
    CONFIG_BOOTCOMMAND="env set bootcmd_usb0 \"devnum=0; run usb_boot\"; env set boot_targets \"usb0 mmc2 mmc1 mmc0\"; run distro_bootcmd"
  '';
}
