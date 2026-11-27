{
  lib,
  quibble,
  pkgsCross,
  zfs-uefi,
}:

# Quibble with a real freestanding runtime instead of upstream's dummies.
#
# It tracks the same upstream revision as `quibble` (maharmstone/quibble master,
# pinned in ../quibble/package.nix).  Every change this variant makes is local
# and lives beside this file: print-dummies.patch, setjmp.S and compat.cpp.
#
# Upstream's print.cpp defines _setjmp as a stub that returns 0 and aborts from
# longjmp, strrchr, strncpy, strtoul and the printf backends, so FreeType's
# raster-overflow and validator recovery paths are disabled.  This variant
# deletes that block and links in setjmp.S (a full Windows x64 jmp_buf
# save/restore) and compat.cpp (string and non-va_list printf entry points), the
# same shape the base package used before it followed upstream's stubs.
#
# The toolchain patch in the base package is reused unchanged: the real runtime
# is swapped in through the QUIBBLE_RT_ARCHIVE flag.  The patches need rebasing
# when upstream next touches print.cpp; the update script only bumps the base.
#
# It also ships zfs.efi (from zfs-uefi) next to btrfs.efi and ntfs.efi, so
# quibble can load Windows from a ZFS pool.  The pool's file system root is
# bootfs, or the pool root when that is unset; SystemPath keeps the ordinary
# multi(0)disk(0)rdisk(0)partition(N)\Windows form because the driver does not
# implement GetArcName; the pool must stay within FreeBSD's features_for_read
# (no encryption, no gzip/zstd); and OpenZFS.sys must be a boot-start driver in
# the guest's SYSTEM hive.
let
  mingw = pkgsCross.mingw-msvcrt-x86_64;

  runtime = mingw.stdenv.mkDerivation {
    pname = "quibble-patched-runtime";
    inherit (quibble) version;
    dontUnpack = true;

    buildPhase = ''
      runHook preBuild
      $CXX -c ${./compat.cpp} -o compat.o -ffreestanding -fno-stack-protector -fno-exceptions
      $CC -c ${./setjmp.S} -o setjmp.o
      $AR rcs libquibble-rt.a compat.o setjmp.o
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm644 libquibble-rt.a $out/lib/libquibble-rt.a
      runHook postInstall
    '';
  };
in
quibble.overrideAttrs (old: {
  pname = "quibble_patched";

  patches = (old.patches or [ ]) ++ [ ./print-dummies.patch ];

  cmakeFlags = map (
    flag:
    if lib.hasPrefix "-DQUIBBLE_RT_ARCHIVE=" flag then
      "-DQUIBBLE_RT_ARCHIVE=${runtime}/lib/libquibble-rt.a"
    else
      flag
  ) (old.cmakeFlags or [ ]);

  postInstall = (old.postInstall or "") + ''
    install -Dm644 ${zfs-uefi}/share/zfs-uefi/zfs.efi $out/share/quibble/drivers/zfs.efi
    install -Dm644 ${zfs-uefi}/share/zfs-uefi/LICENCE $out/share/quibble/drivers/zfs-efi-LICENCE
  '';

  meta = (old.meta or { }) // {
    description = "Open-source UEFI bootloader for Windows, with a real setjmp/longjmp runtime";
    longDescription = ''
      Same loader and upstream revision as `quibble`, with two local changes:
      upstream's dummy libc block in print.cpp is replaced by a real
      setjmp/longjmp and string/printf runtime, and the `zfs-efi` driver ships
      in `drivers/` so Windows can be booted from a ZFS pool.

      The install layout is unchanged: `quibble.efi`, `freeldr.ini` and
      `font.ttf` belong in the directory the loader is loaded from, with
      `drivers/` next to them. Booting from ZFS additionally requires the pool
      to stay inside FreeBSD's read-only feature set (no encryption, no
      gzip/zstd) and `OpenZFS.sys` to be a boot-start driver in the guest.
    '';
  };
})
