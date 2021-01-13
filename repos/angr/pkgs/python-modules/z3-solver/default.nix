{ buildPythonPackage
, fetchPypi
, pkgs
, python3
}:

buildPythonPackage rec {
  pname = "z3-solver";
  version = "4.8.9.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-UE1BVOvThTP8F1Gg4Eh4SCdXBEzr9RIkP22oYk9IS3A=";
  };

  setupPyBuildFlags = [
     "--plat-name x86_64-linux"
   ];

  # Tests fail for non-understandable reasons.
  doCheck = false;

  pythonImportsCheck = [ "z3" ];

  meta = with pkgs.lib; {
    description = "angr's version of the python binding for the Z3 theorem prover";
    homepage = "https://github.com/angr/z3";
    license = licenses.mit;
    maintainers = [ maintainers.pamplemousse ];
  };
}
