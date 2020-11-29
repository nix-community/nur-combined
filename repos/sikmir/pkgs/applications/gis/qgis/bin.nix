{ stdenv, fetchurl, undmg, releaseType ? "pr" }:

assert stdenv.lib.assertOneOf "releaseType" releaseType [ "pr" "ltr" ];

stdenv.mkDerivation rec {
  pname = "qgis-bin";
  version = {
    pr = "3.14.16";
    ltr = "3.10.10";
  }.${releaseType};

  src = fetchurl {
    url = "https://qgis.org/downloads/macos/qgis-macos-${releaseType}.dmg";
    sha256 = {
      pr = "103rrzzpd79klaqjja7cydrwhvpqwdn04wp6ggavnxcgigb7z7z8";
      ltr = "0w41bi1lz7c7c9pylnaqp2r50frzq3fdpqznrq7wzq0hkkf49wzg";
    }.${releaseType};
    name = "QGIS-macOS-${version}.dmg";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = if releaseType == "pr" then "QGIS3.14.app" else "QGIS3.10.app";

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
