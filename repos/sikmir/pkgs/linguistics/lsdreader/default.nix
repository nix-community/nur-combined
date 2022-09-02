{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "lsdreader";
  version = "0.2.14";

  src = fetchFromGitHub {
    owner = "sv99";
    repo = "lsdreader";
    rev = "c78ab22e794f1fbfbc93ffb3ee7ae481f54dd8c2";
    hash = "sha256-vTXfWTQ6TUZCyXo/PgJ/JaWf9mseKKQNz1+cA8KOKw0=";
  };

  doCheck = false;

  meta = with lib; {
    description = "Decompile Lingvo LSD dictionary to DSL";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
  };
}
