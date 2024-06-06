{ fetchurl, lib, pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "hiddify";
  version = "1.1.1";

  src = fetchurl {
    url = "https://github.com/hiddify/hiddify-next/releases/download/v${version}/Hiddify-Debian-x64.deb";
    sha256 = "546afb3eded8199714b585cffb1bc075b917f21d78d99b78d26c0d6be79ea7bf";
  };

  buildInputs = with pkgs;[
    dpkg
  ];

  unpackPhase = "dpkg-deb -x $src $out";

  meta = with lib; {
    description = "A multi-platform proxy client based on Sing-box universal proxy tool-chain";
    homepage = https://github.com/hiddify/hiddify-next;
    license = licenses.cc-by-nc-sa-40;
    platforms = with platforms; [
      "x86_64-linux"
    ];
  };
}
