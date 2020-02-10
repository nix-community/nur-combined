{ stdenv, fetchFromGitHub, coq, coq-plugin-lib }:
stdenv.mkDerivation rec {
  name = "coq${coq.coq-version}-fix-to-elim";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "uwplse";
    repo = "fix-to-elim";
    rev = "dd17727d84295354e4a89a41b9e0d2d612af5016";
    sha256 = "13dji6xbdxgi140m81l538jg6l594626gbpwdcad0d56mda4ilkw";
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
