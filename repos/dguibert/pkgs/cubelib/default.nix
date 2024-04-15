{
  stdenv,
  lib,
  fetchurl,
  zlib,
  pkg-config,
  which,
  autoreconfHook,
}:
stdenv.mkDerivation {
  name = "cubelib-4.6";
  src = fetchurl {
    url = "http://apps.fz-juelich.de/scalasca/releases/cube/4.6/dist/cubelib-4.6.tar.gz";
    sha256 = "sha256-Nur/p2iNuLkwTJ5Iyl3E7cLLZlOKr0hle5tczXl5OFs=";
  };
  buildInputs = [zlib];
  postConfigure = ''
    ${lib.optionalString stdenv.cc.isIntel or false ''
      # remove wrong lib path
      echo "PATCHING libtool"
      sed -i.bak -e 's@\(intel-compilers-.*/lib\)\\"@\1@' build-frontend/libtool
    ''}
  '';
  nativeBuildInputs = [pkg-config which autoreconfHook];
  configureFlags = [
    "${lib.optionalString stdenv.cc.isIntel or false "--with-nocross-compiler-suite=intel"}"
  ];
  enableParallelBuilding = true;
}
