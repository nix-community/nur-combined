{ lib
, stdenv
, fetchFromGitHub
, cmake
, pandoc
, boost
, bzip2
, expat
, libosmium
, libpqxx
, libyamlcpp
, protozero
, zlib
}:

stdenv.mkDerivation rec {
  pname = "osmdbt";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "openstreetmap";
    repo = "osmdbt";
    rev = "v${version}";
    hash = "sha256-hXwWOOfvBrJqjMXsG/59J83PHwZqIKm+2B00QYoJD80=";
  };

  nativeBuildInputs = [ cmake pandoc ];

  buildInputs = [
    boost
    bzip2
    expat
    libosmium
    libpqxx
    libyamlcpp
    protozero
    zlib
  ];

  cmakeFlags = [ "-DBUILD_PLUGIN=OFF" ];

  meta = with lib; {
    description = "OSM Database Replication Tools";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
