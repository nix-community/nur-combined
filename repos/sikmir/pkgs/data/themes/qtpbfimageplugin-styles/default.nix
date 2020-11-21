{ stdenv, sources }:

stdenv.mkDerivation {
  pname = "qtpbfimageplugin-styles";
  version = stdenv.lib.substring 0 10 sources.qtpbfimageplugin-styles.date;

  src = sources.qtpbfimageplugin-styles;

  dontBuild = true;

  installPhase = ''
    install -dm755 $out/share/gpxsee/style
    cp -r Mapbox OpenMapTiles Tilezen $out/share/gpxsee/style
  '';

  meta = with stdenv.lib; {
    inherit (sources.qtpbfimageplugin-styles) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
