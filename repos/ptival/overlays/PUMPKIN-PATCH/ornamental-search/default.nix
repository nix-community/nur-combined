{ stdenv, fetchFromGitHub, coq, fix-to-elim }:
stdenv.mkDerivation rec {
  name = "coq${coq.coq-version}-ornamental-search";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "uwplse";
    repo = "ornamental-search";
    rev = "2086a53f06bfa11dcaa133b5c5b9dadc7f02941a";
    sha256 = "13hwnhnbliba23qznivf76nqa0ri7rvzsfl83mk1d8d4mp003dp4";
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
