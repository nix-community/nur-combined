{ lib, stdenv, fetchurl, fetchFromGitHub }:

let
  version = "11.1";
  nnueFile = "berserk-e3f526b26f50.nn";
  nnue = fetchurl {
    name = nnueFile;
    url = "https://github.com/jhonnold/berserk/releases/download/${version}/${nnueFile}";
    hash = "sha256-4/Umsm9QNQOsOHDo1reVKPx6dst8HHCMF0nfpPMGVn0=";
  };
in stdenv.mkDerivation rec {
  pname = "berserk";
  inherit version;

  src = fetchFromGitHub {
    owner = "jhonnold";
    repo = "berserk";
    rev = "463f5a5f2a3a5c562d253efe0115a5bcf11b4b50";
    hash = "sha256-/+q6VkWA+zPOHqUl1daazgA4mo//7t4tO+rkEHEqq0s=";
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
