{ buildPythonPackage
, fetchPypi
, pkgs
, six
}:

buildPythonPackage rec {
  pname = "PySMT";
  version = "0.8.0";

  propagatedBuildInputs = [ six ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "6ccac89f22052f0b12f3847382efe94d0fbda95f33978af29f4f3aee5ef0e270";
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

