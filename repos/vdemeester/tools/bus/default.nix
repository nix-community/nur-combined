{ stdenv, lib, go }:

stdenv.mkDerivation rec {
  name = "bus";
  src = ./.;

  phases = "buildPhase installPhase";
  buildInputs = [ go ];

  buildPhase = ''
    HOME=$(pwd)
    cp $src/main.go .
    go build -o bus main.go
  '';
  installPhase = ''
    mkdir $out
    install -D bus $out/bin/bus
  '';
}
