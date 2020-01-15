{ stdenv, pkgs, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "wait-for-it-${version}";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "vishnubob";
    repo = "wait-for-it";
    rev = "54d1f0bfeb6557adf8a3204455389d0901652242";
    sha256 = "0wzxswdwg6q1wyjfayyk8p22ai36xy5005g8sng4frfhvxx5dhq7";
  };

  phases = [ "unpackPhase" "installPhase" ];
  
  installPhase = ''
    mkdir -p $out/bin
    cp wait-for-it.sh $out/bin
  '';
}
