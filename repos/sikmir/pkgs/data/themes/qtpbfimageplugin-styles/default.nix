{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "qtpbfimageplugin-styles";
  version = "2022-06-08";

  src = fetchFromGitHub {
    owner = "tumic0";
    repo = pname;
    rev = "5b7d248d064b9c9dd9dbb51ebbb0ff9b259045e3";
    hash = "sha256-BbkDHZ/rNbXz7raeQnNiJ4HnhyH5Y/pISYZuk3BYYss=";
  };

  installPhase = ''
    install -dm755 $out/share/gpxsee/style
    cp -r Esri Mapbox OpenMapTiles OrdnanceSurvey Tilezen $out/share/gpxsee/style
  '';

  meta = with lib; {
    description = "QtPBFImagePlugin styles";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
  };
}
