{ lib, stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "inter-font";
  version = "3.19";

  src = fetchurl {
    url = "https://github.com/rsms/inter/releases/download/v3.19/Inter-3.19.zip";
    sha256 = "0ch0rk6nwd80y7vqbmrii9cr3zq6sq2gqpgkxdxsaqhp1livc2hm";
  };

  buildInputs = [ unzip ];

  sourceRoot = "Inter Desktop";

  installPhase = ''
    mkdir -p $out/data/fonts
    cp -v ./* $out/data/fonts
  '';

  meta = {
    description = "A typeface specially designed for user interfaces with focus on high legibility of small-to-medium sized text on computer screens";
    home = https://github.com/rsms/inter;
    license = lib.licenses.ofl;
  };
}
