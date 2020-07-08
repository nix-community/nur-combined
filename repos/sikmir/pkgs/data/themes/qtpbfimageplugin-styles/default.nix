{ stdenv, sources }:

stdenv.mkDerivation {
  pname = "qtpbfimageplugin-styles";
  version = stdenv.lib.substring 0 7 sources.qtpbfimageplugin-styles.rev;
  src = sources.qtpbfimageplugin-styles;

  dontBuild = true;

  installPhase = ''
    install -dm755 $out/share/gpxsee/style
    cp -r Mapbox OpenMapTiles Tilezen $out/share/gpxsee/style
  '';

  meta = with stdenv.lib; {
    inherit (sources.qtpbfimageplugin-styles) description homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
