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

  postPatch = ''
    substituteInPlace src/tilemaker.cpp \
      --replace "config.json" "$out/share/tilemaker/config-openmaptiles.json" \
      --replace "process.lua" "$out/share/tilemaker/process-openmaptiles.lua"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [ boost lua protobuf shapelib sqlite zlib ];

  postInstall = ''
    install -Dm644 $src/resources/* -t $out/share/tilemaker
  '';

  meta = with lib; {
    description = "Make OpenStreetMap vector tiles without the stack";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
