# <repo:u-boot:doc/board/qualcomm/board.rst>
# - "Android bootloader expect gzipped kernel with appended dtb, so let’s mimic linux to satisfy stock bootloader."
# - also: <https://docs.u-boot.org/en/v2024.04/board/qualcomm/sdm845.html>
#
# <https://www.linaro.org/blog/initial-u-boot-release-for-qualcomm-platforms/>
#
# after building, boot/flash like:
# > fastboot boot u-boot.img
# ...
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

  gzip -9 u-boot-nodtb.bin

  # Boot image header v2, as supported by ABL on SDM845 (Pocophone F1).
  # See doc/board/qualcomm/board.rst in U-Boot.
  mkbootimg \
    --pagesize 4096 \
    --header_version 2 \
    --base 0x80000000 \
    --kernel_offset 0x00008000 \
    --kernel u-boot-nodtb.bin.gz \
    --dtb_offset 0x01f00000 \
    --dtb u-boot.dtb \
    --output boot.img

  install boot.img $out
''
