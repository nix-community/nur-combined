{ glibc, gmp, gnat, gprbuild, libiconv, nixpkgs, sources, which, xmlada-bootstrap
}:
nixpkgs.stdenv.mkDerivation {

  buildInputs = [
    gmp
    gprbuild
    libiconv
    which
  ];

  propagatedBuildInputs = [
    gnat
  ];

  configurePhase = ''
    export GPR_PROJECT_PATH="${xmlada-bootstrap}/share/gpr"
    export LIBRARY_PATH="${glibc}/lib"
  '';

  buildPhase = ''
    gprbuild -P iconv/gnatcoll-iconv.gpr
    gprbuild -P gmp/gnatcoll-gmp.gpr
  '';

  name = "gnatcoll-bindings";
  src = fetchTarball { inherit (sources.gnatcoll-bindings) url sha256; };

}
