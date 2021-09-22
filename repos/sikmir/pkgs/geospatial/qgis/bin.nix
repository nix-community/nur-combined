{ lib, stdenv, fetchurl, undmg, releaseType ? "pr" }:

assert lib.assertOneOf "releaseType" releaseType [ "pr" "ltr" ];

stdenv.mkDerivation rec {
  pname = "qgis-bin";
  version = {
    pr = "3.18.1";
    ltr = "3.16.5";
  }.${releaseType};

  src = fetchurl {
    url = "https://qgis.org/downloads/macos/qgis-macos-${releaseType}.dmg";
    sha256 = {
      pr = "04nsxgzi0wc11fvmzakacqmwpi2zqpr70acbkyi407jwg4pb23il";
      ltr = "17y3xia7z5imd1csxiqdxdg9v39ryzl09j9gyfjs8wfqs2rg1yi6";
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
