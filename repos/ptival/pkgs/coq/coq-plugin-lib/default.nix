{ stdenv, fetchFromGitHub, coq }:
stdenv.mkDerivation rec {
  name = "coq${coq.coq-version}-coq-plugin-lib";

  src = fetchFromGitHub {
    owner = "uwplse";
    repo = "coq-plugin-lib";
    rev = "37db8d0ec595bcc7840ad272f9e88555c35f2bc3";
    sha256 = "112aqfgxxqkd92x56hj9nvwvlw38is4db1jv2f8pzh9j1c6mlpsy";
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
