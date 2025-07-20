{ lib
, buildPythonPackage
, fetchPypi
, setuptools_scm
}:

buildPythonPackage rec {
  pname = "prettifyJsonLog";
  version = "1.0.3";

  pyproject = true;
  build-system = [ setuptools_scm ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "w7FFz+mYTKVVB0t+/kjphW0u/QPjHRcjYXi7yb6wWEU=";
  };

  meta = with lib; {
    descripytion = "A small python programm to make json log formats human readable";
    homepage = "https://github.com/neumantm/prettifyJsonLog";
    license = licenses.mit;
  };
}
