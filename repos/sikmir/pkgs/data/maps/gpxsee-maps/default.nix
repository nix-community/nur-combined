{ stdenv, sources }:

stdenv.mkDerivation rec {
  pname = "gpxsee-maps";
  version = stdenv.lib.substring 0 7 src.rev;
  src = sources.gpxsee-maps;

  installPhase = ''
    install -dm755 "$out/share/gpxsee/maps"
    cp -r World "$out/share/gpxsee/maps"
  '';

  meta = with stdenv.lib; {
    inherit (src) description homepage;
    license = licenses.unlicense;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
  };
}
