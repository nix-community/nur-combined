{ stdenv, fetchFromGitHub, coq, fix-to-elim }:
stdenv.mkDerivation rec {
  name = "coq${coq.coq-version}-ornamental-search";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "uwplse";
    repo = "ornamental-search";
    rev = "6177ca37755888aed16bc06e7fc6eb8b117a28c5";
    sha256 = "0w849q1d2ki6ifd8sx1d29qdhickmagw0dsnk09rxm2inkpr8am2";
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
