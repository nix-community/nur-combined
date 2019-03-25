{ lib, pkgs }:

let
  inherit (pkgs) stdenv;
in stdenv.mkDerivation rec {
  version = "28.0.1";
  name = "android-sdk-platform-tools-r${version}";
  src = pkgs.fetchurl {
    url = "https://dl.google.com/android/repository/platform-tools_r${version}-linux.zip";
    sha256 = "14kkr9xib5drjjd0bclm0jn3f5xlmlg652mbv4xd83cv7a53a49y";
  };
  buildInputs = with pkgs; [ unzip ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/platform-tools
    mv -t $out/platform-tools ./*

    mkdir -p $out/bin
    ln -s $out/platform-tools/{adb,fastboot} $out/bin/
  '';

  preFixup = ''
    prefix=$out/platform-tools
    for elf in adb dmtracedump etc1tool e2fsdroid fastboot hprof-conv make_f2fs sload_f2fs sqlite3; do
      patchelf \
        --set-interpreter "${stdenv.cc.libc.out}/lib/ld-linux-x86-64.so.2" \
        --set-rpath "${stdenv.cc.cc.lib.out}/lib:${pkgs.zlib.out}/lib:$prefix/lib64" \
          $prefix/$elf
    done
  '';
}
