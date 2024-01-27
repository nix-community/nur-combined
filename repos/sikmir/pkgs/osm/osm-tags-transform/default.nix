{ lib
, stdenv
, fetchFromGitHub
, cmake
, bzip2
, expat
, libosmium
, lua
, protozero
, zlib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osm-tags-transform";
  version = "2023-08-06";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osm-tags-transform";
    rev = "f8717b52aba371a38e0fe538a6e0b0c1bcc7049d";
    hash = "sha256-X0KsPlNac5ASuYjQRu75t5OL9WJSqIrXYFXyY1qFn+c=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    bzip2
    expat
    libosmium
    lua
    protozero
    zlib
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTS" true)
  ];

  doCheck = true;

  meta = with lib; {
    description = "Transform tags in OSM files using Lua code";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
