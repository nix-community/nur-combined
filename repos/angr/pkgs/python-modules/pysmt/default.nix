{ buildPythonPackage
, fetchFromGitHub
, lib
, pkgs
, six
}:

buildPythonPackage rec {
  pname = "PySMT";
  version = "0.9.0";

  propagatedBuildInputs = [ six ];

  src = fetchFromGitHub {
    owner = "pysmt";
    repo = lib.toLower pname;
    rev = "v${version}";
    sha256 = "sha256-Q+UPLMhLeS5h07q4GyIK7sDBfn+y3A1XmjGEf6cZMhQ=";
  };

  # very long tests
  doCheck = false;

  # Verify import still works.
  pythonImportsCheck = [ "pysmt" ];

  meta = with pkgs.lib; {
    description = "A solver-agnostic library for SMT Formulae manipulation and solving";
    homepage = "https://github.com/pysmt/pysmt";
    license = licenses.bsd2;
    maintainers = [ maintainers.pamplemousse ];
  };
}

