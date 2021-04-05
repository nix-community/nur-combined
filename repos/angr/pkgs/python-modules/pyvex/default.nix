{ archinfo
, bitstring
, cffi
, buildPythonPackage
, future
, fetchPypi
, pkgs
, pycparser
}:

buildPythonPackage rec {
  pname = "pyvex";
  version = "9.0.6588";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-p30ppf/7jd7tCSpYYIbEbUiaUhShsGgp9RBoSGs7a+M=";
  };

  propagatedBuildInputs = [ archinfo bitstring cffi future pycparser ];

  setupPyBuildFlags = [
    "--plat-name x86_64-linux"
  ];

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
