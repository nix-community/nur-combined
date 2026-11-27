{
  stdenv,
  zfs-uefi,
}:

# Upstream's host-side reader test (test/native_read_test.c) built for the
# build machine, so a real pool can be checked without Windows or EFI.  The
# engine is compiled with the same compat shims the driver uses, except the
# headers glibc already provides: test/zap_case_test.c documents that a copy of
# src/compat without them is what the host build wants.
stdenv.mkDerivation {
  pname = "zfs-uefi-native-reader";
  inherit (zfs-uefi) version src patches;

  buildPhase = ''
    runHook preBuild

    cp -r src/compat hostcompat
    rm -f hostcompat/stdio.h hostcompat/assert.h hostcompat/netinet/in.h

    # glibc's sys/cdefs.h has to win, but skein_freebsd.h needs FreeBSD's
    # __min_size, so keep a shim in front of it.
    cat > hostcompat/sys/cdefs.h <<'EOF'
    #pragma once
    #include_next <sys/cdefs.h>
    #ifndef __min_size
    #define __min_size(x) static (x)
    #endif
    #ifndef __unused
    #define __unused __attribute__((__unused__))
    #endif
    #ifndef __printflike
    #define __printflike(f, a) __attribute__((__format__(__printf__, f, a)))
    #endif
    EOF

    $CC -std=gnu11 -O2 -w -D_GNU_SOURCE \
      -Wno-error=implicit-function-declaration \
      -Wno-error=implicit-int -Wno-error=int-conversion \
      -include hostcompat/prefix.h -I hostcompat -I src/engine -I src \
      -o native_read_test test/native_read_test.c \
      src/engine/nvlist.c src/engine/skein.c src/engine/skein_block.c \
      src/engine/list.c src/engine/blake3_stub.c src/engine/lz4.c

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 native_read_test $out/bin/native_read_test

    runHook postInstall
  '';

  meta = {
    description = "Host build of zfs-uefi's reader test";
    inherit (zfs-uefi.meta) license;
  };
}
