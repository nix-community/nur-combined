{ buildPythonPackage
, fetchPypi
, pkgs
}:

buildPythonPackage rec {
  pname = "minidump";
  version = "0.0.13";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1w93yh2dz7llxjgv0jn7gf9praz7d5952is7idgh0lsyj67ri2ms";
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
