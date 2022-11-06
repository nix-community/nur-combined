{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost
, bzip2
, expat
, fmt
, gdal
, libosmium
, protozero
, sqlite
, zlib
}:

stdenv.mkDerivation rec {
  pname = "osmium-surplus";
  version = "2022-08-28";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osmium-surplus";
    rev = "e977028727ed9c836cefad3a271040dbe5b2bf7d";
    hash = "sha256-Cl7Umi/hn+Kbd5YDV89EmpsL6vm+n5Snt3ceiH4clUY=";
  };

  postPatch = lib.optionalString stdenv.isDarwin ''
    # broken on darwin
    substituteInPlace src/CMakeLists.txt \
      --replace "exec(osp-find-multipolygon-problems" "#" \
      --replace "exec(osp-find-relation-problems" "#"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    bzip2
    expat
    fmt
    gdal
    libosmium
    protozero
    sqlite
    zlib
  ];

  meta = with lib; {
    description = "Collection of assorted small programs based on the Osmium framework";
    homepage = "https://github.com/osmcode/osmium-surplus";
    license = with licenses; [ gpl3Plus boost ];
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
