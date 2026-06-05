{
  buildPackages,
  dtc,
  runCommand,
  ubootSamsungChromebook,
  ubootTools,
  vboot_reference,
}: runCommand "kernel-partition" {
  preferLocalBuild = true;
  nativeBuildInputs = [
    vboot_reference
    dtc
    ubootTools
  ];
  meta = {
    longDescription = ''
      this is a payload image for the baked-in platform firmware.
      flash this directly to the "platform partition", and then the Samsung Chromebook (google-snow)
      bootrom will load that as its next stage. from there, we can perform a more standard nixos boot procedure.
    '';
  };
} ''
  # according to depthcharge-tools, bootloader.bin is legacy, was used by the earliest
  # chromebooks (H2C) *only*.
  dd if=/dev/zero of=dummy_bootloader.bin bs=512 count=1
  echo auto > dummy_config.txt

  # from uboot snow_defconfig, also == CONFIG_SYS_LOAD_ADDR
  CONFIG_TEXT_BASE=0x43e00000

  cp ${ubootSamsungChromebook}/u-boot.bin .
  ubootFlags=(
    -A arm         # architecture
    -O linux       # operating system
    -T kernel      # image type
    -C none        # compression
    -a $CONFIG_TEXT_BASE  # load address (CONFIG_TEXT_BASE)
    -e $CONFIG_TEXT_BASE  # entry point (CONFIG_SYS_LOAD_ADDR), i.e. where u-boot `bootm` should jump to to execute the kernel
    -n nixos-uboot # image name
    -d u-boot.bin  # image data
    u-boot.fit     # output
  )
  mkimage "''${ubootFlags[@]}"

  futility \
    --debug \
  vbutil_kernel \
    --version 1 \
    --bootloader ./dummy_bootloader.bin \
    --vmlinuz u-boot.fit \
    --arch arm \
    --keyblock ${buildPackages.vboot_reference}/share/vboot/devkeys/kernel.keyblock \
    --signprivate ${buildPackages.vboot_reference}/share/vboot/devkeys/kernel_data_key.vbprivk \
    --config ./dummy_config.txt \
    --pack $out
''
