# Patched Wine mspatcha DLLs required to apply Acrobat DC MSP updates.
# Synced with AUR acroread-dc-wine 26.002.22031-2 (Smoolak): builds only mspatcha
# from ajkhoury's Wine tree + mspatcha-pe-validation.patch.
{
  lib,
  stdenv,
  fetchurl,
  bison,
  flex,
  pkgsCross,
}:

let
  wineCommit = "11a9c08f0acdd7d3cac863d90f6670840c778c34";
  mingw32 = pkgsCross.mingw32.buildPackages.gcc;
  mingw64 = pkgsCross.mingwW64.buildPackages.gcc;
in
stdenv.mkDerivation {
  pname = "adobe-acrobat-mspatcha";
  version = "0-unstable-2026-01-12";

  src = fetchurl {
    url = "https://gitlab.winehq.org/ajkhoury/wine/-/archive/${wineCommit}/wine-${wineCommit}.tar.bz2";
    hash = "sha256-NJlByliwvBdRYXFiNKTto/4+xcWx89JW4yfaK2aqcQc=";
  };

  patches = [ ./mspatcha-pe-validation.patch ];

  strictDeps = true;

  nativeBuildInputs = [
    bison
    flex
    mingw32
    mingw64
  ];

  enableParallelBuilding = true;

  # Out-of-tree build like AUR PKGBUILD (winegcc links against build-tree objects).
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    mkdir build-mspatcha
    cd build-mspatcha
    ../configure \
      --prefix=/ \
      --enable-archs=i386,x86_64 \
      --without-alsa \
      --without-cups \
      --without-dbus \
      --without-fontconfig \
      --without-freetype \
      --without-gnutls \
      --without-gstreamer \
      --without-opencl \
      --without-pcap \
      --without-pulse \
      --without-sdl \
      --without-udev \
      --without-unwind \
      --without-usb \
      --without-vulkan \
      --without-wayland \
      --without-x

    make -j''${NIX_BUILD_CORES:-1} \
      dlls/mspatcha/i386-windows/mspatcha.dll \
      dlls/mspatcha/x86_64-windows/mspatcha.dll

    # Relink without --wine-builtin so the DLLs load as native overrides (AUR).
    tools/winegcc/winegcc \
      -o "$NIX_BUILD_TOP/mspatcha-x64.dll" \
      --wine-objdir . \
      -b x86_64-w64-mingw32 \
      -shared \
      ../dlls/mspatcha/mspatcha.spec \
      dlls/mspatcha/x86_64-windows/lzxd_dec.o \
      dlls/mspatcha/x86_64-windows/md5.o \
      dlls/mspatcha/x86_64-windows/mspatcha_main.o \
      dlls/mspatcha/x86_64-windows/pa19.o \
      dlls/mspatcha/version.res \
      dlls/winecrt0/x86_64-windows/libwinecrt0.a \
      dlls/ucrtbase/x86_64-windows/libucrtbase.a \
      dlls/kernel32/x86_64-windows/libkernel32.a \
      dlls/ntdll/x86_64-windows/libntdll.a

    tools/winegcc/winegcc \
      -o "$NIX_BUILD_TOP/mspatcha-x86.dll" \
      --wine-objdir . \
      -b i686-w64-mingw32 \
      -shared \
      ../dlls/mspatcha/mspatcha.spec \
      dlls/mspatcha/i386-windows/lzxd_dec.o \
      dlls/mspatcha/i386-windows/md5.o \
      dlls/mspatcha/i386-windows/mspatcha_main.o \
      dlls/mspatcha/i386-windows/pa19.o \
      dlls/mspatcha/version.res \
      dlls/winecrt0/i386-windows/libwinecrt0.a \
      dlls/ucrtbase/i386-windows/libucrtbase.a \
      dlls/kernel32/i386-windows/libkernel32.a \
      dlls/ntdll/i386-windows/libntdll.a \
      -Wl,--disable-stdcall-fixup

    x86_64-w64-mingw32-strip --strip-unneeded "$NIX_BUILD_TOP/mspatcha-x64.dll"
    i686-w64-mingw32-strip --strip-unneeded "$NIX_BUILD_TOP/mspatcha-x86.dll"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 "$NIX_BUILD_TOP/mspatcha-x64.dll" $out/lib/mspatcha-x64.dll
    install -Dm644 "$NIX_BUILD_TOP/mspatcha-x86.dll" $out/lib/mspatcha-x86.dll
    runHook postInstall
  '';

  meta = with lib; {
    description = "Patched Wine mspatcha DLLs for Adobe Acrobat Reader DC MSP updates";
    homepage = "https://gitlab.winehq.org/ajkhoury/wine";
    license = licenses.lgpl21Plus;
    platforms = [ "x86_64-linux" ];
  };
}
