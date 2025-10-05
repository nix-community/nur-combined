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
  protozero,
  yaml-cpp,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osmdbt";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "openstreetmap";
    repo = "osmdbt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-boc6LYSAt1txSeMQPuEGpBoivQCQbc9XqlfFJbWctDc=";
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
    protozero
    yaml-cpp
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
