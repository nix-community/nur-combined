{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qtpbfimageplugin-styles";
  version = "2022-06-08";

  src = fetchFromGitHub {
    owner = "tumic0";
    repo = "qtpbfimageplugin-styles";
    rev = "5b7d248d064b9c9dd9dbb51ebbb0ff9b259045e3";
    hash = "sha256-BbkDHZ/rNbXz7raeQnNiJ4HnhyH5Y/pISYZuk3BYYss=";
  };

  installPhase = ''
    install -dm755 $out
    cp -r Esri Mapbox OpenMapTiles OrdnanceSurvey Tilezen $out
  '';

  meta = {
    description = "QtPBFImagePlugin styles";
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
  };
})
