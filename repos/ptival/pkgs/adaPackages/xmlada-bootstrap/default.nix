{ glibc, gprbuild-bootstrap, nixpkgs, sources }:
nixpkgs.stdenv.mkDerivation {

  buildInputs = [
    gprbuild-bootstrap
  ];

  configurePhase = ''
    export LIBRARY_PATH="${glibc}/lib"
    ./configure --prefix=$out
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    make install
  '';

  name = "xmlada-bootstrap";
  src = fetchTarball { inherit (sources.xmlada) url sha256; };

}
