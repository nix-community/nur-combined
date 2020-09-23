{ nixpkgs, sources }:
nixpkgs.stdenv.mkDerivation {

  buildPhase = ''
    # do nothing
  '';

  configurePhase = ''
    # do nothing
  '';

  installPhase = ''
    mkdir -p $out
    cp -r ./* $out/
  '';

  name = "xmlada-source";
  src = fetchTarball { inherit (sources.xmlada) url sha256; };
}
