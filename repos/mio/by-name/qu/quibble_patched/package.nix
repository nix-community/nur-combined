{
  lib,
  quibble,
  pkgsCross,
}:

# Quibble with a real freestanding runtime instead of upstream's dummies.
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

  meta = (old.meta or { }) // {
    description = "Open-source UEFI bootloader for Windows, with a real setjmp/longjmp runtime";
  };
})
