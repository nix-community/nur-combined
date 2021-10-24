{ lib, buildPythonPackage, fetchFromGitHub, poetry, typing-extensions }:
buildPythonPackage rec {
  pname = "returns";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "dry-python";
    repo = pname;
    rev = "5f30030473e06f1c55b057f95171d5523f13ca94";
    sha256 = "05aqmpk7cps6xn9ab2bs39l4nbbdl10bn1mvfchhrkm3bbj99863";
  };

  format = "pyproject";
  nativeBuildInputs = [ poetry ];
  propagatedBuildInputs = [ typing-extensions ];

  meta = with lib; {
    description = "Make your functions return something meaningful, typed, and safe!";
    homepage = https://returns.readthedocs.io;
    license = licenses.bsd2;
    broken = true;
  };
}

