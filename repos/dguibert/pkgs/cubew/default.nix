{
  stdenv,
  lib,
  fetchurl,
  autoreconfHook,
}:
stdenv.mkDerivation {
  name = "cubew-4.6";
  src = fetchurl {
    url = "http://apps.fz-juelich.de/scalasca/releases/cube/4.6/dist/cubew-4.6.tar.gz";
    sha256 = "sha256-mf5YznqxMGHr+8NgrtrswoCZowY2xSaaQsDLr1cUmqg=";
  };
  configureFlags = [
    "${lib.optionalString stdenv.cc.isIntel or false "--with-nocross-compiler-suite=intel"}"
  ];
  nativeBuildInputs = [autoreconfHook];
}
