{ lib, stdenv, fetchFromGitHub, cmake
, bzip2, expat, libosmium, lua, protozero, zlib
}:

stdenv.mkDerivation rec {
  pname = "osm-tags-transform";
  version = "2022-02-19";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = pname;
    rev = "d8f8f729cddee97964081de25e591428dd610a9a";
    hash = "sha256-PBxH5RGoimX+pyr17UAMJVbdknciT8M8WCzw6tWLwEs=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    bzip2 expat libosmium lua protozero zlib
  ];

  cmakeFlags = [ "-DBUILD_TESTS=ON" ];

  doCheck = true;

  meta = with lib; {
    description = "Transform tags in OSM files using Lua code";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
