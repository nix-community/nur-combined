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
  version = "8.20.7.27";

  propagatedBuildInputs = [ cachetools decorator future PySMT z3-solver ];

  src = fetchFromGitHub {
    owner = "angr";
    repo = "claripy";
    rev = "ae67818b5af72ecec1d77d1fbc7336d98fc4b5e5";
    sha256 = "0abfxswqfn822j46dxs0ga738mg1sgyf0kkr12hk44n95vpfzz7f";
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
