{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pandoc,
  boost,
  bzip2,
  expat,
  libosmium,
  libpqxx,
  libyamlcpp,
  protozero,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osmdbt";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "openstreetmap";
    repo = "osmdbt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hXwWOOfvBrJqjMXsG/59J83PHwZqIKm+2B00QYoJD80=";
  };

  nativeBuildInputs = [
    cmake
    pandoc
  ];

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

  cmakeFlags = [ (lib.cmakeBool "BUILD_PLUGIN" false) ];

  meta = {
    description = "OSM Database Replication Tools";
    homepage = "https://github.com/openstreetmap/osmdbt";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
