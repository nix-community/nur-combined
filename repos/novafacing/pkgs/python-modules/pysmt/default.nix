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
    sha256 = "0w72y1gfwfjgkzr8m5rkbylvs3sdx7pq4ww4yc90nbq54agwijkc";
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

