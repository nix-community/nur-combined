{ stdenv, lib, bash, makeWrapper }:

stdenv.mkDerivation rec {
  name = "nix-search";

  src = ./.;

  buildInputs = [ bash ];

  installPhase = ''
    mkdir -p $out/bin
    cp nix-search writeOpts writePacks $out/bin
  '';

  meta = {
    version = "0.1.0";
    description = "nix-search";
  };
}
