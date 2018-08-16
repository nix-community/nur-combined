{ stdenv, lib, pkgs, fetchFromGitHub, ... }:
stdenv.mkDerivation rec {
  name = "PkgDecrypt-2017-12-01";
  rev = "e2f9518";

  src = fetchFromGitHub {
    owner = "St4rk";
    repo = "PkgDecrypt";
    inherit rev;
    sha256 = "0dk13qamxyny0vc990s06vqddxwwc6xmikb1pkc3rnys98yda29p";
  };

  installPhase = ''
    install -m755 -D pkg_dec $out/bin/pkg_dec
    install -m755 -D make_key $out/bin/make_key
  '';

  buildInputs = with pkgs;[
    zlib
  ];

  meta = {
    homepage = https://github.com/St4rk/PkgDecrypt;
    description = "St4rk's Vita pkg decrypter";
    license = lib.licenses.gpl2;
  };
}
