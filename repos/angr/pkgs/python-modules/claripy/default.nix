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
  version = "9.0.6588";

  propagatedBuildInputs = [ cachetools decorator future PySMT setuptools z3-solver ];

  src = fetchFromGitHub {
    owner = "angr";
    repo = "claripy";
    rev = "v${version}";
    sha256 = "sha256-ycgGN4hQvUQsOviw3TV+6cjgNUFEFKa0K5s31W44QpE=";
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
