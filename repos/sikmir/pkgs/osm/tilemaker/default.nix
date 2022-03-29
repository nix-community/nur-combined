{ lib, stdenv, fetchFromGitHub, cmake, installShellFiles
, boost, lua, protobuf, rapidjson, shapelib, sqlite, zlib }:

stdenv.mkDerivation rec {
  pname = "tilemaker";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "systemed";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-st6WDCk1RZ2lbfrudtcD+zenntyTMRHrIXw3nX5FHOU=";
  };

  postPatch = ''
    substituteInPlace src/tilemaker.cpp \
      --replace "config.json" "$out/share/tilemaker/config-openmaptiles.json" \
      --replace "process.lua" "$out/share/tilemaker/process-openmaptiles.lua"
  '';

  nativeBuildInputs = [ cmake installShellFiles ];

  buildInputs = [ boost lua protobuf rapidjson shapelib sqlite zlib ];

  postInstall = ''
    installManPage $src/docs/man/tilemaker.1
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
