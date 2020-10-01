{ buildPythonPackage
, fetchPypi
, pkgs
}:

buildPythonPackage rec {
  pname = "minidump";
  version = "0.0.13";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-uoqYj5FeUwBfi0dHUVJp56t8k3vHSrCf7JSe3wT0I/E=";
  };

  # No tests.
  doCheck = false;

  # Verify import still works.
  pythonImportsCheck = [ "minidump" ];

  meta = with pkgs.lib; {
    description = "Python library to parse and read Microsoft minidump file format";
    homepage = "https://github.com/skelsec/minidump";
    license = licenses.bsd2;
    maintainers = [ maintainers.pamplemousse ];
  };
}
