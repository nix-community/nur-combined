{ stdenv, fetchFromGitHub, coq, coq-plugin-lib, fix-to-elim, ornamental-search
}:
stdenv.mkDerivation rec {
  name = "coq${coq.coq-version}-PUMPKIN-PATCH";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "uwplse";
    repo = "PUMPKIN-PATCH";
    rev = "07a55c68ddbaa1ffe7c105f30cae2c0cd59fd1f6";
    sha256 = "1pl8mmk0mhgqgjnznmxgsq40yvlbvwq38k9yfs8y3lx7pf3z9gfl";
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
