{ buildPythonPackage
, fetchPypi
, pkgs
}:

buildPythonPackage rec {
  pname = "minidump";
  version = "0.0.10";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0v4racmwag3rdpq0yy7ri6q0gplm0wxxcczyr12b6vgz7brncs7i";
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
