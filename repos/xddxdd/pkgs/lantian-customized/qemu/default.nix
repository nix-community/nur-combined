{
  SDL2,
  dxvk_2,
  fetchFromGitHub,
  lib,
  patchelf,
  qemu,
  xxd,
}:

let
  qemuVmvgaSrc = fetchFromGitHub {
    owner = "qemus";
    repo = "qemu-vmvga";
    tag = "v1.0.2";
    hash = "sha256-0EQY8t8QUpUAPOJ34Bba3HzkKuwIicH3THwRI5/Kh9c=";
  };

  nvkvmSrc = fetchFromGitHub {
    owner = "reindertpelsma";
    repo = "nvkvm-pv";
    tag = "v0.2.5";
    hash = "sha256-tehLWMg2DR6+JpQCvbieS0M88S/7u9Do037wvp8KEz8=";
  };

  # nixpkgs patches DXVK to load its SDL2 by absolute path, which bypasses the
  # headless SDL2 that the vmvga device installs in the loader under the
  # libSDL2-2.0.so.0 soname. Restore the by-soname lookup.
  dxvk = dxvk_2.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/wsi/sdl2/wsi_platform_sdl2.cpp \
        --replace-fail '${lib.getLib SDL2}/lib/libSDL2-2.0.so.0' 'libSDL2-2.0.so.0'
    '';
  });
in
(qemu.override {
  hostCpuTargets = [ "x86_64-softmmu" ];
  # The vmvga device refuses to install its headless SDL2 when a real libSDL2
  # is already loaded, as QEMU linked against SDL2 would have loaded.
  sdlSupport = false;
  openGLSupport = true;
}).overrideAttrs
  (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [
      patchelf
      xxd
    ];

    buildInputs = old.buildInputs ++ [ dxvk ];

    configureFlags = old.configureFlags ++ [ "--extra-cflags=-DNVKVM_STUB_EMBEDDED" ];

    postPatch = (old.postPatch or "") + ''
      # The nvkvm series is ordered against one exact QEMU release.
      for nvkvmPatch in ${nvkvmSrc}/patches/*.patch; do
        echo "applying $(basename "$nvkvmPatch")"
        patch -p1 --batch --forward --no-backup-if-mismatch < "$nvkvmPatch"
      done

      cp ${qemuVmvgaSrc}/hw/display/*.c hw/display/
      rm -rf hw/display/include
      cp -r ${qemuVmvgaSrc}/hw/display/include hw/display/include
      cp ${qemuVmvgaSrc}/hw/i386/vmport.c hw/i386/vmport.c
      cp ${qemuVmvgaSrc}/hw/i386/vmport-vmvga.h hw/i386/vmport-vmvga.h

      cp -r ${nvkvmSrc} "$TMPDIR/nvkvm-src"
      chmod -R u+w "$TMPDIR/nvkvm-src"
      make -C "$TMPDIR/nvkvm-src/src/stub" CC="$CC" XXD=xxd READELF=readelf

      mkdir -p hw/misc/nvkvm_inc
      cp ${nvkvmSrc}/src/qemu/*.c ${nvkvmSrc}/src/qemu/*.h hw/misc/
      cp ${nvkvmSrc}/src/abi/*.h ${nvkvmSrc}/src/common/*.h hw/misc/nvkvm_inc/
      cp ${nvkvmSrc}/src/qemu/nvkvm_linux_types.h hw/misc/nvkvm_inc/linux_types_compat.h
      cp "$TMPDIR/nvkvm-src/src/stub/nvkvm_stub_bin.h" hw/misc/nvkvm_stub_bin.h

      sed -i -E \
        's#"\.\./\.\./src/(common|abi)/([A-Za-z0-9_]+\.h)"#"nvkvm_inc/\2"#g' \
        hw/misc/*.c hw/misc/*.h
      sed -i 's|#include <linux/types.h>|#include "linux_types_compat.h"|g' \
        hw/misc/nvkvm_inc/*.h
    '';

    postFixup = (old.postFixup or "") + ''
      # The DXVK libraries are only dlopened, so the linker never puts their
      # directory on the rpath.
      for emulator in $out/bin/qemu-system-* $out/bin/.qemu-system-*-wrapped; do
        [ -f "$emulator" ] || continue
        patchelf --add-rpath ${lib.getLib dxvk}/lib "$emulator"
      done
    '';

    passthru = old.passthru // {
      updateScript = [ (toString ./update.sh) ];
    };

    meta = old.meta // {
      maintainers = with lib.maintainers; [ xddxdd ];
      # nixpkgs gives qemu a platform pattern rather than a list; the nvkvm and
      # dxvk parts are Linux-only anyway.
      platforms = lib.platforms.linux;
    };
  })
