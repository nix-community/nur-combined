{ lib, stdenv, fetchFromGitHub, autoreconfHook, expat, zlib }:

stdenv.mkDerivation rec {
  pname = "overpass-api";
  version = "0.7.55";

  src = fetchFromGitHub {
    owner = "drolbr";
    repo = "Overpass-API";
    rev = "osm3s-v${version}";
    hash = "sha256-Hf2uLVeBo95bQKubX1CSJZIEYiL2CdwjtDwSr6yOjwU=";
  };

  sourceRoot = "${src.name}/src";

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ expat zlib ];

  meta = with lib; {
    description = "A database engine to query the OpenStreetMap data";
    homepage = "http://overpass-api.de/";
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
