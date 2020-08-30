{ archinfo
, bitstring
, cffi
, unicorn
, buildPythonPackage
, future
, fetchPypi
, pkgs
}:

buildPythonPackage rec {
  pname = "pyvex";
  version = "8.20.7.27";

  propagatedBuildInputs = [ archinfo bitstring cffi future ];

  setupPyBuildFlags = [
    "--plat-name x86_64-linux"
  ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "00wsvasz90kjdng0cff5fma5y3gjj674lf2sx2zzgpca4szgki6b";
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
