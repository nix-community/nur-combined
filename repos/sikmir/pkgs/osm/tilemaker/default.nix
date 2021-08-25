{ lib, stdenv, fetchFromGitHub, cmake
, boost, lua, protobuf, shapelib, sqlite, zlib }:

stdenv.mkDerivation rec {
  pname = "tilemaker";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "systemed";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-RfWf5e7yyfoJO3S8u6DwpB5xYl4PGnlhk+E1l+ewNN8=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ boost lua protobuf shapelib sqlite zlib ];

  meta = with lib; {
    description = "Make OpenStreetMap vector tiles without the stack";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
