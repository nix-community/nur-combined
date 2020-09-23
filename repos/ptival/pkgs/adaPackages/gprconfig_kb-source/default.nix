{ nixpkgs, sources }:
nixpkgs.stdenv.mkDerivation {

  buildPhase = "echo SKIPPED";

  configurePhase = "echo SKIPPED";

  installPhase = ''
    mkdir -p $out
    cp -r ./* $out/
  '';

  name = "gprconfig_kb-source";
  src = fetchTarball { inherit (sources.gprconfig_kb) url sha256; };

}
