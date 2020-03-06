{ stdenv, fetchFromGitHub, coq }:
stdenv.mkDerivation rec {
  name = "coq${coq.coq-version}-coq-plugin-lib";

  src = fetchFromGitHub {
    owner = "uwplse";
    repo = "coq-plugin-lib";
    rev = "9ef820a05b779d69d5f175dd7840444012267db6";
    sha256 = "1s20zwq2j3ar3kkp48jjgm1dp5x8vf32fm7qwmajqgkllhg6pj4h";
  };

  buildInputs = [ coq ];
  propagatedBuildInputs = with coq.ocamlPackages;
    [
      camlp5
      findlib
      ocaml
    ];

  enableParallelBuilding = true;

  preBuild = "coq_makefile -f _CoqProject -o Makefile";

  installFlags = "COQLIB=$(out)/lib/coq/${coq.coq-version}/";

  passthru = {
    compatibleCoqVersions = v: v == "8.8";
  };
}
