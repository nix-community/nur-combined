{ buildPythonPackage
, fetchPypi
, pkgs
, python3
}:

buildPythonPackage rec {
  pname = "z3-solver";
  version = "4.8.8.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "03xsxy6pw09vzlm9hv9l501zdw5p7fn4l4ih8v0agzdrdm399ncl";
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
