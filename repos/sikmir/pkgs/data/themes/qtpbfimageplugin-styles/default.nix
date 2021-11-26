{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "qtpbfimageplugin-styles";
  version = "2021-11-08";

  src = fetchFromGitHub {
    owner = "tumic0";
    repo = pname;
    rev = "44eecbdab00d08ebf22ccd4a1c0011fa73e1c66e";
    hash = "sha256-HHysZp83YoYs+A3p8Ia07XsCuf1/LWbTsIysEqhHmZI=";
  };

  installPhase = ''
    install -dm755 $out/share/gpxsee/style
    cp -r Mapbox OpenMapTiles OrdnanceSurvey Tilezen $out/share/gpxsee/style
  '';

  meta = with lib; {
    description = "QtPBFImagePlugin styles";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
  };
}
