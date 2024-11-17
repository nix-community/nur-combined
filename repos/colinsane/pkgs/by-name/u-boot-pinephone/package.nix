{
  armTrustedFirmwareAllwinner,
  buildUBoot,
  crust-firmware-pinephone,
  fetchpatch,
  lib,
  linux-megous,
}:

(buildUBoot {
  defconfig = "pinephone_defconfig";
  filesToInstall = [
    "u-boot"  #< ELF file
    "u-boot.bin"  #< raw binary, load it into RAM and jump to it
    "u-boot-sunxi-with-spl.bin"  #< this is what Tow-Boot releases appear to be
    "u-boot.cfg"  #< copy of Kconfig which this u-boot was compiled with
    "u-boot.dtb"
    "u-boot.map"
    "u-boot-nodtb.bin"
    "u-boot.sym"
  ];
}).overrideAttrs (base: {
  # patches = (base.patches or []) ++ [
  #   # (fetchpatch {
  #   #   # see: <https://gitlab.com/postmarketOS/pmaports/-/issues/1945>
  #   #   # Pinephone has multiple hardware revs, notably 1.2 and 1.2b.
  #   #   # stock u-boot can't differentiate these, and so tries to boot a 1.2b phone
  #   #   # using the 1.2 device tree, which leads (notably) to a non-functional compass (magnetometer).
  #   #   url = "https://github.com/Tow-Boot/U-Boot/pull/2.diff";
  #   #   hash = "sha256-o0p+M+cLgJ+pcmAHCFEzIZuFKl0ytZRkM4Qy7Hau4io=";
  #   #   name = "sunxi: pinephone: detect existed magnetometer and fixup dtb";
  #   # })
  #   # (fetchpatch {
  #   #   url = "https://git.uninsane.org/colin/u-boot/commit/6dfa30fc8bb73e840e6ee1ef3849c6344d5fe6c6.diff";
  #   #   name = "sunxi: pinephone: force 1.2b magnetometer";
  #   #   hash = "sha256-64pFPYDZPTkIjmqQiqrPTxbK5b7TlKTZ3R0Ufe2+w+s=";
  #   # })
  #   linux-megous.patches.af8133j
  # ];
  # postPatch = (base.postPatch or "") + ''
  #   substituteInPlace configs/pinephone_defconfig \
  #     --replace 'CONFIG_DEFAULT_DEVICE_TREE="sun50i-a64-pinephone-1.2"' 'CONFIG_DEFAULT_DEVICE_TREE="sun50i-a64-pinephone-1.2b"' \
  #     --replace 'CONFIG_OF_LIST="sun50i-a64-pinephone-1.1 sun50i-a64-pinephone-1.2"' 'CONFIG_OF_LIST="sun50i-a64-pinephone-1.1 sun50i-a64-pinephone-1.2b"'
  # '';

  env = (base.env or {}) // {
    BL31 = "${armTrustedFirmwareAllwinner}/bl31.bin";
    SCP = "${crust-firmware-pinephone}/scp.bin";
  };
})
