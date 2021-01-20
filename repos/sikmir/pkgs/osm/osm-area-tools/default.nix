{ stdenv
, fetchFromGitHub
, cmake
, boost
, bzip2
, expat
, gdal
, libosmium
, protozero
, sqlite
, zlib
, sources
}:

stdenv.mkDerivation rec {
  pname = "osm-area-tools";
  version = stdenv.lib.substring 0 10 sources.osm-area-tools.date;

  src = sources.osm-area-tools;

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    bzip2
    expat
    gdal
    (libosmium.overrideAttrs (old: {
      cmakeFlags = [ "-DINSTALL_GDALCPP:BOOL=ON" ];
    }))
    protozero
    sqlite
    zlib
  ];

  meta = with stdenv.lib; {
    inherit (sources.osm-area-tools) description homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
