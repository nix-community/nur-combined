{ gnat, gprconfig_kb-source, nixpkgs, sources, xmlada-source }:
nixpkgs.stdenv.mkDerivation {

  propagatedBuildInputs = [
    gnat
  ];

  configurePhase = ''
    patchShebangs ./bootstrap.sh
  '';

  buildPhase = ''
    ./bootstrap.sh --with-xmlada=${xmlada-source} --with-kb=${gprconfig_kb-source} --prefix=$out
  '';

  installPhase = ''
    # do nothing
  '';

  name = "gprbuild-bootstrap";
  src = fetchTarball { inherit (sources.gprbuild) url sha256; };

}
