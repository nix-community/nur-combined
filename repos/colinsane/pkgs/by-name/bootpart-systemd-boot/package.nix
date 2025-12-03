{
  lib,
  runCommandLocal,
  systemd,
}:
runCommandLocal "bootpart-systemd-boot" {
  meta = {
    description = "unmanaged files to place in /boot on a systemd-boot system";
    longDescription = ''
      provides:
      - EFI/BOOT/BOOTX64.EFI: the UEFI-spec default entry, when the BIOS doesn't know about any other entries.
      - EFI/systemd/systemd-bootx64.efi: an EFI entry point one can configure the BIOS to boot,
        in case there are multiple EFI entries.
        use `efibootmgr` CLI tool to register this with the BIOS.
    '';
    inherit (systemd.meta) platforms;
  };
} ''
  mkdir -p $out/EFI/BOOT $out/EFI/systemd
  # install the systemd boot entry
  cp ${lib.getLib systemd}/lib/systemd/boot/efi/systemd-boot*.efi $out/EFI/systemd

  # install EFI/BOOT/$default.efi and stubs (which may or may not be necessary?),
  # where `default` is a architecture-specific path,
  # e.g. `bootx64` or `bootaa64`
  cp ${systemd}/lib/systemd/boot/efi/* $out/EFI/BOOT
  booter=$(basename $(ls $out/EFI/BOOT/systemd-*.efi))
  mv $out/EFI/BOOT/$booter $out/EFI/BOOT/''${booter/systemd-/}
''

