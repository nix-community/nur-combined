{ lib, stdenv, fetchurl, fetchFromGitHub }:

let
  version = "12.1";
  nnueFile = "berserk-fb675dad41b4.nn";
  nnueVersion = "12";
  nnue = fetchurl {
    name = nnueFile;
    url = "https://github.com/jhonnold/berserk/releases/download/${nnueVersion}/${nnueFile}";
    hash = "sha256-+2ddrUG0X3KgMDefECJBJwSmhVT3A8y0B0dAQ2QLr8c=";
  };
in stdenv.mkDerivation rec {
  pname = "berserk";
  inherit version;

  src = fetchFromGitHub {
    owner = "jhonnold";
    repo = "berserk";
    rev = "refs/tags/${version}";
    hash = "sha256-jiYbR5XzNPzLjqO1DWRNsFwxNqhIVOpshguJHugqD3I=";
  };

  preConfigure = ''
    cd src
    substituteInPlace makefile --replace-fail native x86-64-v3
    substituteInPlace makefile --replace-fail ": clone-networks" ":"
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
