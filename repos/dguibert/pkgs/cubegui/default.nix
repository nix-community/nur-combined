{ stdenv, fetchurl
, cubelib
, qt5
, perl
, which
}:

stdenv.mkDerivation {
  name = "cubegui-4.4.2";
  src = fetchurl {
    url = "http://apps.fz-juelich.de/scalasca/releases/cube/4.4/dist/cubegui-4.4.2.tar.gz";
    sha256 = "0yzca23g0850f4rf77anjbxnby9vjs1shcahbwrgh9552sb4gdi9";
  };
  #configureFlags = [
  #  "${stdenv.lib.optionalString stdenv.cc.isIntelCompilers or false "--with-nocross-compiler-suite=intel"}"
  #];
  buildInputs = [ cubelib qt5.qtbase perl which ];
  enableParallelBuilding = true;
}
