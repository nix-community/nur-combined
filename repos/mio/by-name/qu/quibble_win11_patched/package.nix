{
  writeShellApplication,
  quibble_win11,
  quibble_patched,
  zfs-uefi,
}:

# The Windows 11 loader and the patched runtime together.
#
# `quibble_win11` carries the loader changes of PR #144, which zfs-efi's README
# says Windows 11 needs, but ships no ZFS driver.  `quibble_patched` ships
# zfs.efi but follows upstream master, so it is the Windows 10 loader.  Windows
# 11 booted from ZFS needs both, which is why this variant exists.
#
# Everything patched comes from `quibble_patched` (its real setjmp/longjmp and
# string/printf runtime, its print-dummies.patch, and the zfs.efi install), and
# everything branch-specific comes from `quibble_win11` (the source pin and the
# installPhase, which reads that tree's README/LICENCE/font.ttf instead of
# master's).
quibble_patched.overrideAttrs (old: {
  pname = "quibble_win11_patched";

  inherit (quibble_win11) version src installPhase;

  # This variant has no pins of its own: the loader follows `quibble_win11` and
  # the ZFS driver follows `zfs-uefi`.  Bumping both together keeps the shipped
  # zfs.efi from drifting behind the loader it was tested with.
  passthru = (old.passthru or { }) // {
    updateScript = writeShellApplication {
      name = "update-quibble_win11_patched";
      runtimeInputs = [
        quibble_win11.passthru.updateScript
        zfs-uefi.passthru.updateScript
      ];
      text = ''
        update-quibble_win11 "$@"
        update-zfs-uefi "$@"
      '';
    };
  };

  meta = (old.meta or { }) // {
    description = "Open-source UEFI bootloader for Windows 11, with a real setjmp/longjmp runtime and the ZFS driver";
    longDescription = ''
      The openzfsonwindows `win11` branch of Quibble (PR #144) with the two
      changes `quibble_patched` makes on master: upstream's dummy libc block in
      print.cpp is replaced by a real setjmp/longjmp and string/printf runtime,
      and `zfs-efi` ships in `drivers/` so Windows can be booted from a ZFS
      pool.

      Use this variant for Windows 11 on ZFS.  Windows 10 on ZFS is served by
      `quibble_patched`; Windows 11 without ZFS only needs `quibble_win11`.

      The install layout is unchanged: `quibble.efi`, `freeldr.ini` and
      `font.ttf` belong in the directory the loader is loaded from, with
      `drivers/` next to them.  Booting from ZFS additionally requires the pool
      to stay inside FreeBSD's read-only feature set (no gzip/zstd; encrypted
      datasets are supported) and `OpenZFS.sys` to be a boot-start driver in
      the guest.
    '';
    homepage = "https://github.com/openzfsonwindows/quibble";
  };
})
