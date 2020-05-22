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
  #  "${stdenv.lib.optionalString stdenv.cc.isIntel or false "--with-nocross-compiler-suite=intel"}"
  #];
  buildInputs = [ cubelib qt5.qtbase perl which ];
  enableParallelBuilding = true;
  meta = {
    # /nix/store/2dfjlvp38xzkyylwpavnh61azi0d168b-binutils-2.31.1/bin/ld: cannot find -lcube.tools.common
    broken = true;
  };
}
