{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  clang,
  openmp,
  llvm,
  version,
  python,
  flang_src,
  libpgmath,
  wrapCC,
}: let
  gcc_ =
    if stdenv.cc.isGNU
    then stdenv.cc.cc
    else stdenv.cc.cc.gcc;
  gcc = wrapCC (gcc_.override {
    name = "gcc";
    langFortran = true;
  });

  src = flang_src;

  self = stdenv.mkDerivation {
    name = "flang-${version}";

    buildInputs = [cmake gcc llvm clang python];
    propagatedBuildInputs = [openmp libpgmath];

    NIX_CFLAGS_COMPILE = "-Wno-error=unused-result -Wno-builtin-memcpy-chk-size";

    inherit src;

    cmakeFlags = [
      "-DTARGET_ARCHITECTURE=x86_64" # uname -i
      "-DTARGET_OS=Linux" # uname -s
      "-DCMAKE_CXX_COMPILER=clang++"
      "-DCMAKE_C_COMPILER=clang"
      "-DCMAKE_Fortran_COMPILER=flang"
      "-DLLVM_CONFIG=${llvm}/bin/llvm-config"
    ];

    postFixup = ''
      for lib in libflang libflangrti; do
        rpath=$(patchelf --print-rpath $out/lib/$lib.so)
        patchelf --set-rpath ${openmp}/lib:$rpath:${libpgmath}/lib/libpgmath.so $out/lib/$lib.so
        patchelf --replace-needed libpgmath.so ${libpgmath}/lib/libpgmath.so $out/lib/$lib.so
      done
    '';

    enableParallelBuilding = false; # https://github.com/conda-forge/flang-feedstock/issues/4

    passthru =
      {
        isClang = true;
        langFortran = true;
        inherit llvm;
      }
      // lib.optionalAttrs stdenv.isLinux {
        inherit gcc;
      };

    meta = {
      description = "A fortran frontend for the llvm compiler";
      homepage = http://llvm.org/;
      license = lib.licenses.ncsa;
      platforms = lib.platforms.all;
    };
  };
in
  self
