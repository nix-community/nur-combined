{ lib, stdenv, fetchurl, fetchFromGitHub, glibc }:

let
  nnueFile = "berserk-70370ef71611.nn";
  nnue = fetchurl {
    name = nnueFile;
    url = "https://github.com/jhonnold/berserk-networks/raw/main/${nnueFile}";
    sha256 = "sha256-cDcO9xYRWOHJmMGGpeFiEAH2kSF+Km2x0Dah6PTNEbc=";
  };
in stdenv.mkDerivation rec {
  pname = "berserk";
  version = "9";

  src = fetchFromGitHub {
    owner = "jhonnold";
    repo = "berserk";
    rev = "${version}";
    sha256 = "sha256-z3D1mwVpwozXOlWg2+jpO6ZXcl2wWqpk67LGCnqpqZs=";
  };

  postUnpack = ''
    sourceRoot+=/src
    echo ${nnue}
    cp "${nnue}" "$sourceRoot/networks/${nnueFile}"
  '';

  installPhase = ''
    mkdir -p $out/bin
    install berserk-${version}* $out/bin/
  '';

  buildInputs = [ glibc.static ];
  makeFlags = [ "EVALFILE=networks/${nnueFile}" "PREFIX=$(out)"];
  buildFlags = [ "release" ];

  enableParallelBuilding = true;

  meta = with lib; {
    homepage = "https://github.com/jhonnold/berserk";
    description = "Strong open source UCI chess engine written in C";
    maintainers = with maintainers; [ foolnotion ];
    platforms = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" ];
    license = licenses.gpl3Only;
  };
}
