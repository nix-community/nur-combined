{
  lib,
  fetchurl,
  cubelib,
  qt5,
  perl,
  which,
}:
qt5.mkDerivation {
  name = "cubegui-4.6";
  src = fetchurl {
    url = "http://apps.fz-juelich.de/scalasca/releases/cube/4.6/dist/cubegui-4.6.tar.gz";
    sha256 = "sha256-GHHGc2Eh2UoiMUy12qjzy7l4tYv+VPZ3xMnJaTdX0MU=";
  };
  #configureFlags = [
  #  "${lib.optionalString stdenv.cc.isIntel or false "--with-nocross-compiler-suite=intel"}"
  #];
  buildInputs = [cubelib qt5.qtbase perl which];
  enableParallelBuilding = true;
  meta = {
    # /nix/store/2dfjlvp38xzkyylwpavnh61azi0d168b-binutils-2.31.1/bin/ld: cannot find -lcube.tools.common
    #broken = true;
  };
}
