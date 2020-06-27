{ stdenv, sources }:

stdenv.mkDerivation rec {
  pname = "qtpbfimageplugin-styles";
  version = stdenv.lib.substring 0 7 src.rev;
  src = sources.qtpbfimageplugin-styles;

  dontBuild = true;

  installPhase = ''
    install -dm755 "$out/share/gpxsee/style"
    cp -r Mapbox OpenMapTiles Tilezen "$out/share/gpxsee/style"
  '';

  meta = with stdenv.lib; {
    inherit (src) description homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
