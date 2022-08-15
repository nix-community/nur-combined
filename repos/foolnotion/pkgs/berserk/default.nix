{ lib, stdenv, fetchurl, fetchFromGitHub }:

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
    rev = "beddea23b7d27057748ac6765937fe843cbfe076";
    sha256 = "sha256-ptFJOPrvRwLbG9W3zKMOWSPaGNnksrpYq1qbGG/WjIg=";
  };

  preConfigure = ''
    cd src
    substituteInPlace makefile --replace native x86-64-v3
    substituteInPlace makefile --replace ": clone-networks" ":"
    cp ${nnue} networks/${nnueFile}
  '';

  installPhase = ''
    mkdir -p $out/bin
    install berserk $out/bin/
    install networks/${nnueFile} $out/bin/
  '';

  makeFlags = [ "VERSION=${version}" "PREFIX=$(out)"];
  enableParallelBuilding = true;

  meta = with lib; {
    homepage = "https://github.com/jhonnold/berserk";
    description = "Strong open source UCI chess engine written in C";
    maintainers = with maintainers; [ foolnotion ];
    platforms = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" ];
    license = licenses.gpl3Only;
  };
}
