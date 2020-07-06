{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "batzconverter";
  version = "1.0.1";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "chmouel";
    repo = "batzconverter";
    rev = "${version}";
    sha256 = "0cngxk2z98d11vs5n9mbrk0qscrf0f14jg801im334mp33hd3ad4";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp batz.sh $out/bin/batz
    chmod +x $out/bin/batz
  '';
}
