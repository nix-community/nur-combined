# DEBUGGING
# - if it fails to load menu.c32, or anything, just type 'nixos-default', to boot the default entry.
{
  runCommandLocal,
  syslinux,
}:

let
  syslinux' = syslinux.overrideAttrs (upstream: {
    # XXX: without this `timeout = 50` in syslinux fails to actually auto-boot.
    # bisected to:
    #     commit f2389281fb6f47beefa7a147ed94e857501001f8
    #     Merge: e64186cc27ea dd80ca4d00c6
    #     Author: Robert Scott <code@humanleg.org.uk>
    #     Date:   2024-06-03 19:52:30 +0100
    #
    #         Merge pull request #316761 from risicle/ris-zerocallusedregs-default
    #
    #         stdenv: promote `zerocallusedregs` to `defaultHardeningFlags`
    #
    # this continues to be true at least through 2025-08-09.
    # TODO: upstream
    hardeningDisable = upstream.hardeningDisable ++ [
      "zerocallusedregs"
    ];
  });
in
runCommandLocal "bootpart-syslinux" {
  meta = {
    description = "unmanaged files to place in /boot on a x86-64 extlinux system";
    longDescription = ''
      provides:
      - EFI/BOOT/BOOTX64.EFI: the UEFI-spec default entry, when the BIOS doesn't know about any other entries.
      - EFI/syslinux/syslinux.efi: an EFI entry point one can configure the BIOS to boot,
        in case there are multiple EFI entries.
        use `efibootmgr` CLI tool to register this with the BIOS.
    '';
    platforms = [ "x86_64-linux" ];
  };
} ''
  # populate the EFI directory with syslinux, and configure it to read the extlinux.conf file managed by nixos.
  # i populate two entries: /EFI/syslinux, for EFI-program-aware bootloaders (which may host multiple EFI programs),
  # and /EFI/BOOT/BOOTX64.EFI, for older bootloaders that hardcode the EFI program to load.
  for entry in BOOT syslinux; do
    mkdir -p $out/EFI/$entry
    cp -R ${syslinux'}/share/syslinux/efi64/* $out/EFI/$entry
    install -Dm644 ${./EFI/syslinux/syslinux.cfg} $out/EFI/$entry/syslinux.cfg
    if [ "$entry" = "BOOT" ]; then
      mv $out/EFI/$entry/syslinux.efi $out/EFI/$entry/BOOTX64.EFI
    fi
  done

  # we create this "trampoline" layer so that we can setup the UI directive
  install -Dm644 ${./syslinux/syslinux.cfg} $out/syslinux/syslinux.cfg
''
