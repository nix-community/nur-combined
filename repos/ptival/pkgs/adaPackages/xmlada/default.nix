{ glibc, gprbuild, nixpkgs, sources }:
nixpkgs.stdenv.mkDerivation {

  buildInputs = [
    gprbuild
  ];

  configurePhase = ''
    ./configure --prefix=$out
    export LIBRARY_PATH="${glibc}/lib"
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    make install
  '';

  name = "xmlada";
  src = fetchTarball { inherit (sources.xmlada) url sha256; };

}
