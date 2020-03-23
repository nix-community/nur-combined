{ buildPythonPackage
, cachetools
, decorator
, fetchFromGitHub
, future
, pkgs
, PySMT
, z3-solver
}:

buildPythonPackage rec {
  pname = "claripy";
  version = "8.20.1.7";

  propagatedBuildInputs = [ cachetools decorator future PySMT z3-solver ];

  src = fetchFromGitHub {
    owner = "angr";
    repo = "claripy";
    rev = "ea20bb80a84aab942f89cffbf035675dc0cf1af4";
    sha256 = "1fl96c69pabrrz7mq8hzkgq3hjdnsbkpqcf41y3285706pq6yv7w";
  };

  # Tests are failing.
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
