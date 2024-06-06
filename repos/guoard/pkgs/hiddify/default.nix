{ fetchurl, lib, pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "hiddify";
  version = "1.4.0";

  src = fetchurl {
    url = "https://github.com/hiddify/hiddify-next/releases/download/v${version}/Hiddify-Debian-x64.deb";
    sha256 = "dca0a36a31cc883aab39d46191989b6079fe2fc40d4ea4c9b20d152820b26a85";
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
