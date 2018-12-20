{ stdenv, fetchurl }:
stdenv.mkDerivation {
  name = "otf2-2.1.1";
  src = fetchurl {
    url = "http://www.vi-hps.org/upload/packages/otf2/otf2-2.1.1.tar.gz";
    sha256 = "1ls7rz6qwnqbkifpafc95bnfh3m9xbs74in8zxlnhfbgwx11nn81";
  };
  configureFlags = [
    #"--with-frontend-compiler-suite=(gcc|ibm|intel|pgi|studio)"
    "${stdenv.lib.optionalString stdenv.cc.isIntelCompilers or false "--with-nocross-compiler-suite=intel"}"
  ];
}

