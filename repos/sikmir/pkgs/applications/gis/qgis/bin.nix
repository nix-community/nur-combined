{ stdenv, fetchurl, undmg, releaseType ? "pr" }:

assert stdenv.lib.assertOneOf "releaseType" releaseType [ "pr" "ltr" ];

stdenv.mkDerivation rec {
  pname = "qgis-bin";
  version = {
    pr = "3.16.1";
    ltr = "3.10.12";
  }.${releaseType};

  src = fetchurl {
    url = "https://qgis.org/downloads/macos/qgis-macos-${releaseType}.dmg";
    sha256 = {
      pr = "0dbzwdzlxbvy095lxklgxdrpi7kd4j3m08y33ba7h140yh1yw9xs";
      ltr = "0hzjj3nrd7k54ryim5rlmv40ziy97z505xwzzsdxx3dhpvbkminw";
    }.${releaseType};
    name = "QGIS-macOS-${version}.dmg";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = if releaseType == "pr" then "QGIS.app" else "QGIS${stdenv.lib.substring 0 4 version}.app";

  installPhase = ''
    mkdir -p $out/Applications/QGIS.app
    cp -r . $out/Applications/QGIS.app
  '';

  meta = with stdenv.lib; {
    description = "A Free and Open Source Geographic Information System";
    homepage = "https://qgis.org";
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
