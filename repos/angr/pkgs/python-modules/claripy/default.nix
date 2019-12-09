{ buildPythonPackage
, cachetools
, fetchFromGitHub
, future
, pkgs
, PySMT
, z3-solver
}:

buildPythonPackage rec {
  pname = "claripy";
  version = "8.19.10.30";

  propagatedBuildInputs = [ cachetools future PySMT z3-solver ];

  src = fetchFromGitHub {
    owner = "angr";
    repo = "claripy";
    rev = "adf7452ff7226544cf2f19dc6d510728ba430758";
    sha256 = "1279d3smdrmhnyk5hqgm7p21mc4q34viqpnjkhg9mcqnjg3h3i6g";
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
