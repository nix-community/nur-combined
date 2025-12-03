{
  edk2-rpi4,
  raspberrypifw,
  runCommandLocal,
}:
runCommandLocal "bootpart-edk2-rpi" {
  meta = {
    description = ''
      unmanaged files to place in /boot on a Raspberry Pi 400 system.
      these files are not enough on their own to boot a kernel,
      but only to boot an EFI application.
      best paired with systemd-boot (via `bootpart-systemd-boot`), or perhaps u-boot (untested).
    '';
    platforms = [
      "aarch64-linux"
    ];
  };
} ''
  install -Dm644 ${edk2-rpi4}/RPI_EFI.fd $out/RPI_EFI.fd
  install -Dm644 ${./config.txt} $out/config.txt
  install -Dm644 ${raspberrypifw}/share/raspberrypi/boot/fixup4.dat $out/fixup4.dat
  install -Dm644 ${raspberrypifw}/share/raspberrypi/boot/start4.elf $out/start4.elf
  # N.B.: there are weird incompatibilities between raspberrypifw (start4.elf) and edk2.
  # it seems that if the two binaries are on different versions, then the dtb resolves some discrepencies:
  # - allows systemd-boot to autoboot after 5s (else, it lacks its countdown ... uart problems?)
  # but generally, omitting this .dtb probably won't totally break the boot.
  install -Dm644 ${raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-400.dtb $out/bcm2711-rpi-400.dtb
  # install -Dm644 ${raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb $out/bcm2711-rpi-4-b.dtb
  # install -Dm644 ${raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4.dtb $out/bcm2711-rpi-cm4.dtb
''
