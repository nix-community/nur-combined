{ gprbuild, nixpkgs, sources
}:
nixpkgs.stdenv.mkDerivation {

  buildInputs = [
    gprbuild
  ];

  name = "libadalang";
  src = fetchTarball { inherit (sources.gprbuild) url sha256; };

}
