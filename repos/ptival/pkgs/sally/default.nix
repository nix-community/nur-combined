{ fetchFromGitHub, lib, stdenv
, boost, cmake, gmp, libpoly, makeWrapper, openjdk, opensmt2, pkgconfig, yices, z3
}:
stdenv.mkDerivation rec {

  name = "sally-${version}";
  version = "20190815";

  src = fetchFromGitHub {
    owner  = "SRI-CSL";
    repo   = "sally";
    rev    = "8ab3d761eb663f07f3f6471b4129c2a5e4f7e36f";
    sha256 = "0c2qvyzqgraxcqbqia1pfpngazd30jji19vdi06m2s7cyh0q5k4a";
  };

  buildInputs = [ boost libpoly yices z3 ];

  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Debug" ];

  nativeBuildInputs = [
    cmake
    gmp
    makeWrapper
    openjdk
    opensmt2
    pkgconfig
  ];

  # Darwin uses clang, which issues this warning as an error
  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-Wno-return-std-move";

  NIX_LDFLAGS = "-lboost_iostreams -lboost_program_options -lboost_thread -lboost_system";

  meta = {
    description = "A model checker for infinite-state systems.";
    homepage    = "http://sri-csl.github.io/sally/";
    license     = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.ptival ];
  };

  patchPhase = ''
    patchShebangs antlr/antlr3
  '';

}
