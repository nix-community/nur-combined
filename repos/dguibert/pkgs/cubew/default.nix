{ stdenv, fetchurl, autoreconfHook }:

stdenv.mkDerivation {
  name = "cubew-4.4.1";
  src = fetchurl {
    url = "http://apps.fz-juelich.de/scalasca/releases/cube/4.4/dist/cubew-4.4.1.tar.gz";
    sha256 = "0rsby0ikln36jik4199z9k0q0imcgg6smpy75kpfvsrk6md3z7n0";
  };
  configureFlags = [
    "${stdenv.lib.optionalString stdenv.cc.isIntel or false "--with-nocross-compiler-suite=intel"}"
  ];
  nativeBuildInputs = [ autoreconfHook ];
}
