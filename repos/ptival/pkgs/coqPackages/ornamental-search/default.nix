{ stdenv, fetchFromGitHub, coq, fix-to-elim }:
let
  sources = import ../nix/sources.nix;
in
stdenv.mkDerivation rec {
  name = "coq${coq.coq-version}-ornamental-search";

  src = fetchFromGitHub {
    inherit (sources.ornamental-search) owner repo rev sha256;
    fetchSubmodules = true;
  };

  buildInputs = [
    coq
    fix-to-elim
  ];

  propagatedBuildInputs = with coq.ocamlPackages;
    [
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
