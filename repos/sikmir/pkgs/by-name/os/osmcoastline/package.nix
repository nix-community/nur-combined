{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  bzip2,
  expat,
  gdal,
  geos,
  libosmium,
  protozero,
  sqlite,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osmcoastline";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osmcoastline";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C3jlNZlWwfeP3uXDM+FXHDs8GqxNBxdM4Fu00VMHO0s=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    bzip2
    expat
    gdal
    geos
    libosmium
    protozero
    sqlite
    zlib
  ];

  meta = {
    description = "Extracts coastline data from OpenStreetMap planet file";
    homepage = "https://osmcode.org/osmcoastline/";
    license = lib.licenses.boost;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
