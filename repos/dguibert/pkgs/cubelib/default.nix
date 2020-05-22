{ stdenv, fetchurl, zlib, pkgconfig, which, autoreconfHook }:

stdenv.mkDerivation {
  name = "cubelib-4.4.3";
  src = fetchurl {
    url = "http://apps.fz-juelich.de/scalasca/releases/cube/4.4/dist/cubelib-4.4.3.tar.gz";
    sha256 = "13bshh315hkpgf1pb8anw7slid24dhz7qp8ab571jdxsln0zmm5w";
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
