{
  stdenv,
  requireFile,
  nix-patchtools,
  zlib,
  ncurses,
  libxml2,
  version,
  sha256,
  lib,
  libffi_3_2,
  elfutils,
  rocm-runtime,
}:
stdenv.mkDerivation {
  name = "aocc-${version}";
  src = requireFile {
    url = "https://developer.amd.com/amd-aocc/";
    name =
      if lib.versionOlder version "2.0"
      then "AOCC-${version}-Compiler.tar.xz"
      else "aocc-compiler-${version}.tar";
    inherit sha256;
  };
  dontStrip = true;
  dontPatchELF = true;

  buildInputs = [nix-patchtools];
  libs = lib.makeLibraryPath ([
      stdenv.cc.cc.lib
      /*
      libstdc++.so.6
      */
      #llvmPackages_7.llvm # libLLVM.7.so
      stdenv.cc.cc # libm
      stdenv.glibc
      zlib
      ncurses
      libxml2
      #"${placeholder "out"}/lib"
    ]
    ++ lib.optionals (lib.versionAtLeast version "2.0.0") [
      libffi_3_2
      elfutils
    ]
    ++ lib.optionals (lib.versionAtLeast version "3.1.0") [
      rocm-runtime
    ]);
  installPhase = ''
    mkdir $out
    cp -rv * $out
    rm -rf $out/lib32
    find $out -name "*-i386.so" -delete

    # Hack around lack of libtinfo in NixOS
    ln -s ${ncurses.out}/lib/libncursesw.so.6 $out/lib/libtinfo.so.5
    ln -s ${zlib}/lib/libz.so.1 $out/lib/libz.so.1
    ln -s ${stdenv.glibc}/lib/libdl.so* $out/lib

    export libs=$libs:$out/lib
    echo "LIBS: $libs"
    autopatchelf $out
  '';
  passthru = {
    isClang = true;
    langFortran = true;
  };
}
