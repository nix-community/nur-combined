{ lib, stdenv, fetchurl, fetchFromGitHub }:

let
  version = "13";
  nnueFile = "berserk-d43206fe90e4.nn";
  nnueVersion = "13";
  nnue = fetchurl {
    name = nnueFile;
    url = "https://github.com/jhonnold/berserk/releases/download/${nnueVersion}/${nnueFile}";
    hash = "sha256-1DIG/pDk1HFoFMfnnifwBgsN+DlTnshA7uWk74oxM90=";
  };
in stdenv.mkDerivation rec {
  pname = "berserk";
  inherit version;

  src = fetchFromGitHub {
    owner = "jhonnold";
    repo = "berserk";
    rev = "refs/tags/${version}";
    hash = "sha256-5X58u9RyBmm7l6nft3hTIajwNKVWrlPFO7IMtSdcbPM=";
  };

  preConfigure = ''
    cd src
    substituteInPlace makefile --replace-fail native x86-64-v3
    substituteInPlace makefile --replace-fail ": download-network" ":"
    cp ${nnue} ${nnueFile}
  '';

  installPhase = ''
    mkdir -p $out/bin
    install berserk $out/bin/
    install ${nnueFile} $out/bin/
  '';

  makeFlags = [ "VERBOSE=1" "VERSION=${version}" "PREFIX=$(out)" ];
  enableParallelBuilding = true;

  meta = with lib; {
    homepage = "https://github.com/jhonnold/berserk";
    description = "Strong open source UCI chess engine written in C";
    #maintainers = with maintainers; [ foolnotion ];
    platforms = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" ];
    license = licenses.gpl3Only;
  };
}
