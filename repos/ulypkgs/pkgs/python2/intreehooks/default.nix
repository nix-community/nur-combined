{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytoml,
  pytest,
}:

buildPythonPackage (finalAttrs: {
  pname = "intreehooks";
  version = "1.0";
  format = "setuptools";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-h+YA07Frl+0hnAeGgSYGOed+9aF8Dg291aMC+ZtONOE=";
  };

  propagatedBuildInputs = [ pytoml ];

  checkInputs = [ pytest ];

  meta = {
    description = "Load a PEP 517 backend from inside the source tree";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.fridh ];
    homepage = "https://github.com/takluyver/intreehooks";
  };
})
