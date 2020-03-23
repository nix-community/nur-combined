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
  version = "8.20.1.7";

  propagatedBuildInputs = [ archinfo bitstring cffi future ];

  setupPyBuildFlags = [
    "--plat-name x86_64-linux"
  ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "1kp1la8rjmm6r95dwllqphna4cqwna69z7arc5c763fpc7xlzn0n";
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
