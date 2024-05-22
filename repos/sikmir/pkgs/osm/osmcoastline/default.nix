{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
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
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osmcoastline";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HSUBUSKO0gfUTECjzFpaAu9ye5Qho3rRqhYpc9du+ig=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/osmcode/osmcoastline/commit/67cc33161069f65e315acae952492ab5ee07af15.patch";
      hash = "sha256-6x2WrVm0vI2H8W3jTTdCSlAGNYbc6dfujlr3cHWhC3Y=";
    })
  ];

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

  meta = with lib; {
    description = "Extracts coastline data from OpenStreetMap planet file";
    homepage = "https://osmcode.org/osmcoastline/";
    license = licenses.boost;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
