{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "qtpbfimageplugin-styles";
  version = "2020-04-10";

  src = fetchFromGitHub {
    owner = "tumic0";
    repo = pname;
    rev = "577bb119641c80e1736815ed70a0b99c942c63e0";
    hash = "sha256-HSckGvhuVVLJc2U8Duf2GysRmpzyb8P5taTmW8ZqQe4=";
  };

  installPhase = ''
    install -dm755 $out/share/gpxsee/style
    cp -r Mapbox OpenMapTiles Tilezen $out/share/gpxsee/style
  '';

  meta = with lib; {
    description = "QtPBFImagePlugin styles";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
