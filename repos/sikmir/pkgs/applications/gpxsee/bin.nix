{ lib, stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "gpxsee-bin";
  version = "9.3";

  src = fetchurl {
    url = "mirror://sourceforge/gpxsee/GPXSee-${version}.dmg";
    hash = "sha256-H0PvH1UCwBNGdIwFJcT2dJtDIKyNbHGWC5aD1eOzFiE";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  meta = with lib; {
    description = "GPS log file viewer and analyzer";
    homepage = "https://www.gpxsee.org";
    changelog = "https://build.opensuse.org/package/view_file/home:tumic:GPXSee/gpxsee/gpxsee.changes";
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
