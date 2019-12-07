{ archinfo
, bitstring
, cffi
, buildPythonPackage
, future
, fetchPypi
, pkgs
}:

buildPythonPackage rec {
  pname = "pyvex";
  version = "8.19.10.30";

  propagatedBuildInputs = [ archinfo bitstring cffi future ];

  setupPyBuildFlags = [
    "--plat-name x86_64-linux"
  ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "116qwrg8lh8pbp3xcas69nf9jal847k2ff8zf0gvnrljf544kg9x";
  };

  # Very long tests.
  doCheck = false;

  # Verify import still works.
  pythonImportsCheck = [ "pyvex" ];

  meta = with pkgs.lib; {
    description = "Python bindings for Valgrind's VEX IR";
    homepage = "https://github.com/angr/pyvex";
    license = licenses.bsd2;
    maintainers = [ maintainers.pamplemousse ];
  };
}
