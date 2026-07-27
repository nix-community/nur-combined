{ stdenv, lib, fetchgit, gnumake, zlib, sqlite}:

with lib;

stdenv.mkDerivation rec {
  name = "tippecanoe";

  src = fetchgit {
    url = "https://github.com/mapbox/tippecanoe";
    rev = "df9fa60";
    sha256 = "0rnxivphli84cy8g6nihivp3dg278l5lqlhyjqv3n0g3hbhdvxk2";
  };

  buildInputs =
    [ gnumake zlib sqlite
    ];

  patches = [ ./prefix-fix.patch ];
  postPatch =
    ''
    '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Build vector tilesets from large collections of GeoJSON features";
    homepage = https://github.com/mapbox/tippecanoe;
    license = licenses.bsd2;
    platforms = [ "x86_64-linux" ];
    maintainers = [ maintainers.ingenieroariel ];
  };
}
