{ lib
, stdenv
, fetchFromGitHub
, cmake
, bzip2
, expat
, gdal
, geos
, libosmium
, protozero
, sqlite
, zlib
, sources
}:

stdenv.mkDerivation rec {
  pname = "osmcoastline";
  version = lib.substring 0 10 sources.osmcoastline.date;

  src = sources.osmcoastline;

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    bzip2
    expat
    gdal
    geos
    libosmium
    (libosmium.overrideAttrs (old: rec {
      version = "2.16.0";
      src = fetchFromGitHub {
        owner = "osmcode";
        repo = "libosmium";
        rev = "v${version}";
        sha256 = "1na51g6xfm1bx0d0izbg99cwmqn0grp0g41znn93xnhs202qnb2h";
      };
    }))
    protozero
    sqlite
    zlib
  ];

  meta = with lib; {
    inherit (sources.osmcoastline) description homepage;
    license = licenses.boost;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
