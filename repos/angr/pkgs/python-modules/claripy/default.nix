{ buildPythonPackage
, cachetools
, decorator
, fetchFromGitHub
, future
, pkgs
, PySMT
, setuptools
, z3-solver
}:

buildPythonPackage rec {
  pname = "claripy";
  version = "9.0.4446";

  propagatedBuildInputs = [ cachetools decorator future PySMT setuptools z3-solver ];

  src = fetchFromGitHub {
    owner = "angr";
    repo = "claripy";
    rev = "v${version}";
    sha256 = "sha256-6AP11c4NgbXbS3XVWIW3T8gwdog1nktrrf+KfNqrIz4=";
  };

  # Tests are non-deterministically failing.
  doCheck = false;

  # Verify import still works.
  pythonImportsCheck = [ "claripy" ];

  meta = with pkgs.lib; {
    description = "An abstracted constraint-solving wrapper";
    homepage = "https://github.com/angr/claripy";
    license = licenses.bsd2;
    maintainers = [ maintainers.pamplemousse ];
  };
}
