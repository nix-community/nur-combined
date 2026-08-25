# <repo:u-boot:doc/board/qualcomm/board.rst>
# - "Android bootloader expect gzipped kernel with appended dtb, so let’s mimic linux to satisfy stock bootloader."
# - also: <https://docs.u-boot.org/en/v2024.04/board/qualcomm/sdm845.html>
#
# <https://www.linaro.org/blog/initial-u-boot-release-for-qualcomm-platforms/>
#
# after building, boot/flash like:
# > fastboot boot u-boot.img
# ...
# > fastboot erase boot
# > fastboot flash boot u-boot.img
# > fastboot erase dtbo
# > fastboot reboot
{
  android-tools,
  runCommand,
  ubootPocophone,
}:
runCommand "ablPayloadPocophone" {
  nativeBuildInputs = [ android-tools ];
} ''
  cp ${ubootPocophone}/{u-boot-nodtb.bin,u-boot.dtb} .

  gzip -9 --stdout u-boot-nodtb.bin > u-boot-nodtb.bin.gz
  cat u-boot-nodtb.bin.gz u-boot.dtb > u-boot.bin.gz
  printf '\0' | gzip --stdout > empty.gz

  # this version is handles both `fastboot boot $IMG` and `fastboot flash boot $IMG`
  mkbootimg \
    --pagesize 4096 \
    --base 0x0 \
    --kernel_offset 0x00008000 \
    --os_patch_level 2028-09-21 \
    --ramdisk empty.gz \
    --kernel u-boot.bin.gz \
    --output boot.img

  install boot.img $out
''
