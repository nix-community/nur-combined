{ stdenv, sources }:
let
  pname = "qtpbfimageplugin-styles";
  date = stdenv.lib.substring 0 10 sources.qtpbfimageplugin-styles.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
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
