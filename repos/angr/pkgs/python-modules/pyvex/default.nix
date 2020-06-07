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
  version = "8.20.6.1";

  propagatedBuildInputs = [ archinfo bitstring cffi future ];

  setupPyBuildFlags = [
    "--plat-name x86_64-linux"
  ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "17jz05s2950rv18vc6m23qp99hizdhl3z5i919dabhb1z5fpql7l";
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
