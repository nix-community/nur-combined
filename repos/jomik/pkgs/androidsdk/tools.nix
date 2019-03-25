{ lib, pkgs, pkgsi686Linux }:

let
  inherit (pkgs) stdenv;
  inherit (stdenv.lib) makeLibraryPath;
  stdenv_32bit = pkgsi686Linux.stdenv;
  zlib_32bit = pkgsi686Linux.zlib;
  ncurses_32bit = pkgsi686Linux.ncurses5;
in stdenv.mkDerivation rec {
  version = "26.1.1";
  name = "android-sdk-tools-r${version}";
  src = pkgs.fetchurl {
    url = "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip";
    sha256 = "92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9";
  };
  buildInputs = with pkgs; [ unzip makeWrapper file jdk ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/tools
    mv -t $out/tools ./*
    ln -s $out/tools/bin $out/bin
  '';

  preFixup = ''
    prefix=$out/tools
    patchelf \
      --set-interpreter ${stdenv_32bit.cc.libc.out}/lib/ld-linux.so.2 \
      --set-rpath ${stdenv_32bit.cc.cc.lib}/lib \
        $prefix/mksdcard

    ${if stdenv.hostPlatform.system == "x86_64-linux" then '' 
      patchelf \
        --set-interpreter ${stdenv.cc.libc.out}/lib/ld-linux-x86-64.so.2 \
          $prefix/lib/monitor-x86_64/monitor
      patchelf \
        --set-rpath ${with pkgs; with xorg; makeLibraryPath [ libX11 libXext libXrender freetype fontconfig ]}  \
          $prefix/lib/monitor-x86_64/libcairo-swt.so
      wrapProgram $prefix/lib/monitor-x86_64/monitor \
        --prefix LD_LIBRARY_PATH : ${with pkgs; with xorg; makeLibraryPath [ gtk2 atk stdenv.cc.cc libXtst ]}
    '' else ""}

    wrapProgram $prefix/bin/sdkmanager \
      --set JAVA_HOME ${pkgs.jdk}
  '';
}
