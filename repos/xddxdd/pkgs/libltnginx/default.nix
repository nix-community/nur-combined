{
  lib, stdenv,
  sources,
  cmake,
  ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.libltnginx) pname version src;

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out/lib
    mv libltnginx.so $out/lib
  '';

  nativeBuildInputs = [
    cmake
  ];
}
