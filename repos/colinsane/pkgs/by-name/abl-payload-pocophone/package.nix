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

  gzip u-boot-nodtb.bin
  cat u-boot-nodtb.bin.gz u-boot.dtb > u-boot.bin.gz-dtb

  mkbootimg \
    --kernel_offset 0x00008000 \
    --pagesize 4096 \
    --kernel u-boot.bin.gz-dtb \
    -o boot.img

  # if ABL supports boot image version 2, then we don't need the `cat` parts above
  # mkbootimg \
  #   --pagesize 4096\
  #   --header_version 2 \
  #   --kernel_offset 0x00008000 \
  #   --kernel u-boot-nodtb.bin.gz \
  #   --dtb_offset 0x01f00000 \
  #   --dtb u-boot.dtb \
  #   --output boot.img

  install boot.img $out
''
