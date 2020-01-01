{ stdenv, gpxsee-maps }:

stdenv.mkDerivation rec {
  pname = "gpxsee-maps";
  version = stdenv.lib.substring 0 7 src.rev;
  src = gpxsee-maps;

  installPhase = ''
    install -dm755 "$out/share/gpxsee/maps"
    cp -r World "$out/share/gpxsee/maps"
  '';

  meta = with stdenv.lib; {
    description = gpxsee-maps.description;
    homepage = gpxsee-maps.homepage;
    license = licenses.unlicense;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
  };
}
