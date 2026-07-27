{ lib, stdenv, fetchFromGitHub, glibc, bison, flex, nodejs, mcpp }:

let
  wrapper = ./lslint.js;
in stdenv.mkDerivation rec {
  pname = "lslint";
  version = "1.2.1";
  src = fetchFromGitHub {
    owner = "Makopo";
    repo = "lslint";
    rev = "v${version}";
    sha256 = "1fhkmiznbzld1i6r7lmc7gdyjay82s8kbg9sh9lfd8nfkirkqrxn";
  };

  buildInputs = [ glibc.static nodejs mcpp ];
  nativeBuildInputs = [ bison flex ];
  makeFlags = [ "BUILD_DATE=2019-05-16" ];
  installPhase = ''
    install -m 755 -D ./lslint $out/bin/lslint
    install -m 755 -D ${wrapper} $out/bin/lslint-wrapped
  '';

  postFixup = ''
    substituteInPlace $out/bin/lslint-wrapped \
      --replace "@mcpp@" ${mcpp}/bin/mcpp \
      --replace "@lslint@" $out/bin/lslint
  '';
}
