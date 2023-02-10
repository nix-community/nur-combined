{ lib, stdenv, fetchurl, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "Koivisto";
  version = "9.0";

  src = fetchFromGitHub {
    owner = "Luecx";
    repo = "Koivisto";
    rev = "v${version}";
    sha256 = "sha256-X/wAhMrUhabugA7jFZRWDzoio/9v8/yk60OkJuo7260=";
    fetchSubmodules = true;
  };

  preConfigure = ''
    cd src_files
    substituteInPlace makefile \
      --replace native x86-64-v3 \
      --replace ": updateNetwork" ": "
  '';

  installPhase = ''
    mkdir -p $out/bin
    rm ../bin/*.gcda
    install ../bin/* $out/bin/
  '';

  makeFlags = [ "PREFIX=$(out)" "PEXT=0" "POPCNT=1" "AVX=1" "AVX2=1" "PGO=0" ];
  enableParallelBuilding = true;

  meta = with lib; {
    homepage = "https://github.com/Luecx/Koivisto";
    description = "A strong open-source C++ chess engine";
    #maintainers = with maintainers; [ foolnotion ];
    platforms = [ "x86_64-linux" "i686-linux" ];
    license = licenses.gpl3Only;
  };
}
