{ stdenv, fetchurl, zlib, pkgconfig, which, autoreconfHook }:

stdenv.mkDerivation {
  name = "cubelib-4.4.2";
  src = fetchurl {
    url = "http://apps.fz-juelich.de/scalasca/releases/cube/4.4/dist/cubelib-4.4.2.tar.gz";
    sha256 = "0jgrl4x779pav3ln5w8vabxa76gyriapbq5q9hdkyj9qsb3kacw4";
  };
  buildInputs = [ zlib ];
  postConfigure = ''
    ${stdenv.lib.optionalString stdenv.cc.isIntel or false ''
    # remove wrong lib path
    echo "PATCHING libtool"
    sed -i.bak -e 's@\(intel-compilers-.*/lib\)\\"@\1@' build-frontend/libtool 
    ''}
  '';
  nativeBuildInputs = [ pkgconfig which autoreconfHook ];
  configureFlags = [
    "${stdenv.lib.optionalString stdenv.cc.isIntel or false "--with-nocross-compiler-suite=intel"}"
  ];
  enableParallelBuilding = true;
}
