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
  version = "8.20.6.1";

  propagatedBuildInputs = [ cachetools decorator future PySMT z3-solver ];

  src = fetchFromGitHub {
    owner = "angr";
    repo = "claripy";
    rev = "e152f5851dc625f14e2871982801c21cb88603dc";
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
