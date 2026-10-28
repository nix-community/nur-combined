{
  lib,
  stdenv,
  linuxPackages_latest,
  makeLinuxHeaders,
}:
# Lays nolibc out like a conventional libc so an unmodified gcc driver can
# link against it: crt1.o provides `_start`, and everything else gcc expects
# to find (crti.o, crtn.o, libc.a, ...) exists but is empty. Real nolibc
# functions are `static` in the headers, so they are only available to code
# that includes them.
stdenv.mkDerivation (finalAttrs: {
  pname = "nolibc";

  inherit (linuxPackages_latest.kernel) src version;

  __structuredAttrs = true;
  strictDeps = true;
  postUnpack = ''
    sourceRoot+=/tools/include/nolibc
  '';

  hardeningDisable = [ "all" ];

  buildPhase = ''
    runHook preBuild

    # Compiled with stack protection so the guard initialization and
    # __stack_chk_fail are included; harmless for code built without it.
    echo '#include "nolibc.h"' > crt1.c
    $CC -c -O2 -I. -I${finalAttrs.passthru.linuxHeaders}/include \
      -ffunction-sections -fdata-sections -fno-asynchronous-unwind-tables \
      -fstack-protector-strong ${lib.escapeShellArgs finalAttrs.passthru.stackProtectorFlags} \
      crt1.c -o crt1.o

    $CC -c -x c /dev/null -o empty.o

    runHook postBuild
  '';

  makeFlags = [ "OUTPUT=$(out)/" ];
  installTargets = [ "headers" ];

  postInstall = ''
    mv "$out/sysroot/include" "$out/include"
    rmdir "$out/sysroot"
    ln -s ${finalAttrs.passthru.linuxHeaders}/include/* -t $out/include

    mkdir $out/lib
    install -m644 crt1.o -t $out/lib
    install -m644 empty.o $out/lib/crti.o
    install -m644 empty.o $out/lib/crtn.o
    # Build systems commonly pass these, nolibc implements them in headers
    for name in c m pthread dl rt; do
      $AR rcs $out/lib/lib$name.a
    done
  '';

  passthru = {
    linuxHeaders = makeLinuxHeaders { inherit (finalAttrs) src version; };

    # x86 and powerpc default to a TLS stack canary, but nolibc never sets it
    # up. Code linked against nolibc must use the global `__stack_chk_guard`
    # symbol instead, which nolibc's `_start` initializes.
    stackProtectorFlags = lib.optional (
      stdenv.hostPlatform.isx86 || stdenv.hostPlatform.isPower
    ) "-mstack-protector-guard=global";

    updateScript = null;
  };

  meta = {
    description = "Libc alternative for minimal programs";
    longDescription = ''
      nolibc is an in-kernel, header-only project that implements a useful
      subset of the C standard library and other POSIX/Linux APIs.
    '';
    homepage = "https://github.com/torvalds/linux/blob/master/tools/include/nolibc/nolibc.h";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
})
