{ lib, stdenv, fetchurl, fetchFromGitHub }:

let
  version = "12";
  nnueFile = "berserk-fb675dad41b4.nn";
  nnue = fetchurl {
    name = nnueFile;
    url = "https://github.com/jhonnold/berserk/releases/download/${version}/${nnueFile}";
    hash = "sha256-+2ddrUG0X3KgMDefECJBJwSmhVT3A8y0B0dAQ2QLr8c=";
  };
in stdenv.mkDerivation rec {
  pname = "berserk";
  inherit version;

  src = fetchFromGitHub {
    owner = "jhonnold";
    repo = "berserk";
    rev = "94d48b044bbad8144f7fce7a2848ac888812a1fd";
    hash = "sha256-Nlr8sdB5JulDBJcFpd4GMyvrlm6BrULZ2TPP7z/Xj7E=";
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
