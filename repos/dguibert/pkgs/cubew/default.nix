{ stdenv, fetchurl, autoreconfHook }:

stdenv.mkDerivation {
  name = "cubew-4.4.2";
  src = fetchurl {
    url = "http://apps.fz-juelich.de/scalasca/releases/cube/4.4/dist/cubew-4.4.2.tar.gz";
    sha256 = "0jh1b10z9h97igiqmcdm3r0znxdv3f12ch3bp3i3slp60nd1x9ri";
  };
  configureFlags = [
    "${stdenv.lib.optionalString stdenv.cc.isIntel or false "--with-nocross-compiler-suite=intel"}"
  ];
  nativeBuildInputs = [ autoreconfHook ];
}
