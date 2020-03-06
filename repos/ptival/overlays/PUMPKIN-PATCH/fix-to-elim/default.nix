{ stdenv, fetchFromGitHub, coq, coq-plugin-lib }:
stdenv.mkDerivation rec {
  name = "coq${coq.coq-version}-fix-to-elim";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "uwplse";
    repo = "fix-to-elim";
    rev = "6da6656912be659a27e877e628db4297b6ac3565";
    sha256 = "10l9k3457nvahvigs37nvgk3syr8fqpics74a7h52j8xvf639i7a";
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
