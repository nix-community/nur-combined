{ lib, stdenv, fetchurl, undmg, releaseType ? "pr" }:

assert lib.assertOneOf "releaseType" releaseType [ "pr" "ltr" ];

stdenv.mkDerivation rec {
  pname = "qgis-bin";
  version = {
    pr = "3.18.0";
    ltr = "3.16.4";
  }.${releaseType};

  src = fetchurl {
    url = "https://qgis.org/downloads/macos/qgis-macos-${releaseType}.dmg";
    sha256 = {
      pr = "19xan98lzzmlbzs5m2filma1j6mybajzjf0vxhk3q0b7qwk77c2v";
      ltr = "1k2d2lp925rnb3n6xm8drgrddrjyiyiadahi7bhlq4f3wmy5qfi8";
    }.${releaseType};
    name = "QGIS-macOS-${version}.dmg";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  meta = with lib; {
    description = "A Free and Open Source Geographic Information System";
    homepage = "https://qgis.org";
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
