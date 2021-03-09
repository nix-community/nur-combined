{ lib, stdenv, fetchurl, undmg, releaseType ? "pr" }:

assert lib.assertOneOf "releaseType" releaseType [ "pr" "ltr" ];

stdenv.mkDerivation rec {
  pname = "qgis-bin";
  version = {
    pr = "3.16.4";
    ltr = "3.10.14";
  }.${releaseType};

  src = fetchurl {
    url = "https://qgis.org/downloads/macos/qgis-macos-${releaseType}.dmg";
    sha256 = {
      pr = "19xan98lzzmlbzs5m2filma1j6mybajzjf0vxhk3q0b7qwk77c2v";
      ltr = "1wbikyqjsi19pi6ns9jqw9plbn5j5j0cyzd3davn2yf8vrp2b4lw";
    }.${releaseType};
    name = "QGIS-macOS-${version}.dmg";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = if releaseType == "pr" then "QGIS.app" else "QGIS${lib.substring 0 4 version}.app";

  installPhase = ''
    mkdir -p $out/Applications/QGIS.app
    cp -r . $out/Applications/QGIS.app
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
