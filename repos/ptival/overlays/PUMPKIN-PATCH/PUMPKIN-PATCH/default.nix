{ stdenv, fetchFromGitHub, coq, coq-plugin-lib, fix-to-elim, ornamental-search
}:
stdenv.mkDerivation rec {
  name = "coq${coq.coq-version}-PUMPKIN-PATCH";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "uwplse";
    repo = "PUMPKIN-PATCH";
    rev = "1e4753e0cabf7e674244f570f5a0f9947022e177";
    sha256 = "11jcqiy52dvg4lp51pvjg6w7n7w59qkyray54wkpzr4s8bga41x6";
  };

  buildInputs = [
    coq
    coq-plugin-lib
    fix-to-elim
    ornamental-search
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
