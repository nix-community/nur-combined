{ stdenv, fetchurl, undmg, releaseType ? "pr" }:

assert releaseType == "pr" || releaseType == "ltr";
let
  pname = "qgis";
  version = {
    pr = "3.14.1";
    ltr = "3.10.8";
  }.${releaseType};
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://qgis.org/downloads/macos/qgis-macos-${releaseType}.dmg";
    sha256 = {
      pr = "09c62yxaj0nc64djjxvk5irm0604phir4bfk1wclimvxqc9dvxwz";
      ltr = "1bwj98rzsh3mlv330wkhv51hx2iywcw4r4vbn80z4cyc6dd6k274";
    }.${releaseType};
    name = "QGIS-macOS-${version}.dmg";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = if releaseType == "pr" then "QGIS$3.14.app" else "QGIS3.app";

  installPhase = ''
    mkdir -p $out/Applications/QGIS.app
    cp -R . $out/Applications/QGIS.app
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
