{ stdenv, GPXSee-maps }:

stdenv.mkDerivation rec {
  pname = "gpxsee-maps";
  version = stdenv.lib.substring 0 7 src.rev;
  src = GPXSee-maps;

  installPhase = ''
    install -dm755 "$out/share/gpxsee/maps"
    cp -r World "$out/share/gpxsee/maps"
  '';

  meta = with stdenv.lib; {
    description = GPXSee-maps.description;
    homepage = "https://github.com/tumic0/GPXSee-maps";
    license = licenses.unlicense;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
