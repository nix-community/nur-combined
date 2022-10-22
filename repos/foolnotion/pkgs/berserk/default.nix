{ lib, stdenv, fetchurl, fetchFromGitHub }:

let
  nnueFile = "berserk-c982d9682d4e.nn";
  nnue = fetchurl {
    name = nnueFile;
    url = "https://github.com/jhonnold/berserk/releases/download/10/${nnueFile}";
    sha256 = "sha256-yYLZaC1OsGIGDymESqqigDlqXL900o1+JfRh6u6L+bc=";
  };
in stdenv.mkDerivation rec {
  pname = "berserk";
  version = "10";

  src = fetchFromGitHub {
    owner = "jhonnold";
    repo = "berserk";
    rev = "f0d32c78654610f4adb0a732cefb0a7419f391a4";
    sha256 = "sha256-PTsp3tPil0Z8Yb2AQ6IwDBNYUVYvXXmdVKPcoprt1Zc=";
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
    #maintainers = with maintainers; [ foolnotion ];
    platforms = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" ];
    license = licenses.gpl3Only;
  };
}
