# u-boot tuned for PinePhone Pro
# install to SD card like:
# - dd if=idbloader.img of=/dev/sdb seek=64 oflag=direct conv=sync
# - dd if=u-boot.itb of=/dev/sdb seek=16384 oflag=direct conv=sync
{
  armTrustedFirmwareRK3399,
  buildUBoot,
}:
buildUBoot {
  defconfig = "pinephone-pro-rk3399_defconfig";
  filesToInstall = [
    "idbloader.img" #< entry point: place it at sector 64 & it'll load whatever's at sector 16384 into RAM and jump to it
    "idbloader-spi.img"  #< idbloader, if you want to flash that to SPI. BROM has a glitch where it fetches 4 KiB blocks from SPI, but loads them into RAM in 2 KiB strides, so this is idbloader.img with 2KiB of zeros after each 2KiB of data.
    "u-boot"  #< ELF file
    "u-boot.bin"  #< raw binary; on an ordinary platform (not RK3399), this would be loaded into ram and jumped to.
    "u-boot-rockchip.bin"
    # "u-boot-rockchip-spi.bin"
    # no toplevel spl, but check spl/u-boot-spl.bin
    "u-boot.cfg"  #< copy of Kconfig which this u-boot was compiled with
    "u-boot.dtb"
    "u-boot.itb"  #< itb binary? the idbloader should load it into RAM and jump to it
    "u-boot.map"
    "u-boot-nodtb.bin"
    "u-boot.sym"
  ];

  # default baud rate is 1500000, which is too fast for some USB <-> serial adapters to do
  # CONFIG_DM_RNG is needed to seed the kernel, and avoid "KASLR disabled due to lack of seed"
  extraConfig = ''
    CONFIG_BAUDRATE=115200
    CONFIG_DM_RNG=y
  '';

  # XXX: RK3399 ships a blob for HDCP (media copy protection) in the trusted firmware.
  #      that can be removed with:
  # `(arm-trusted-firmware.override { unfreeIncludeHDCPBlob = false; }).armTrustedFirmwareRK3399`, if so desired.
  BL31 = "${armTrustedFirmwareRK3399}/bl31.elf";
}
# ).overrideAttrs (upstream: {

# default layout is:
# scriptaddr         = 0x00500000
# script_offset_f    = 0xffe000
# script_size_f      = 0x2000
# pxefile_addr_r     = 0x00600000
# fdt_addr_r         = 0x01e00000
# fdtoverlay_addr_r  = 0x01f00000
# kernel_addr_r      = 0x02080000
# ramdisk_addr_r     = 0x06000000
# kernel_comp_addr_r = 0x08000000
# kernel_comp_size   = 0x2000000
#
# this offers 63.5 MiB for the kernel.
# unfortunately, my bloated kernels can be larger than that, so push the addresses back and hope it works:
# postPatch = (upstream.postPatch or "") + ''
#   substituteInPlace include/configs/rk3399_common.h \
#     --replace-fail ramdisk_addr_r=0x06000000 ramdisk_addr_r=0x0a000000 \
#     --replace-fail kernel_comp_addr_r=0x08000000 kernel_comp_addr_r=0x0c000000
# '';
# })
