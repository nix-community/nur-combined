{ stdenv, fetchFromGitHub, coq, coq-plugin-lib }:
let
  sources = import ../nix/sources.nix;
in
stdenv.mkDerivation rec {
  name = "coq${coq.coq-version}-fix-to-elim";

  src = fetchFromGitHub {
    inherit (sources.fix-to-elim) owner repo rev sha256;
    fetchSubmodules = true;
  };

  buildInputs = [
    coq
    coq-plugin-lib
  ];

  propagatedBuildInputs = with coq.ocamlPackages; [
    camlp5
    findlib
    ocaml
  ];

  enableParallelBuilding = true;

  preBuild = ''
    cd plugin
    coq_makefile -f _CoqProject -o Makefile
  '';

  installFlags = "COQLIB=$(out)/lib/coq/${coq.coq-version}/";

  passthru = {
    compatibleCoqVersions = v: v == "8.8";
  };
}
