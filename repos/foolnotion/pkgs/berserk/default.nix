{ lib, stdenv, fetchurl, fetchFromGitHub }:

let
  nnueFile = "berserk-11a8ee076cec.nn";
  nnue = fetchurl {
    name = nnueFile;
    url = "https://github.com/jhonnold/berserk-networks/raw/main/${nnueFile}";
    sha256 = "sha256-EajuB2zs+XF7M+jSi7LXE5DNAXDX22sz18SVLMuH00A=";
  };
in stdenv.mkDerivation rec {
  pname = "berserk";
  version = "9";

  src = fetchFromGitHub {
    owner = "jhonnold";
    repo = "berserk";
    rev = "527334e771ce9c48eab66136508ee94f7af575d3";
    sha256 = "sha256-ibuPBW8y725RGo14wdvrxnZ+eDvaOU8ptQ+6KuGMQQY=";
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
