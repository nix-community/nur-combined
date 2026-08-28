{
  buildPythonPackage,
  lib,
  fetchPypi,
  setuptools-scm,
  importlib-metadata,
}:

buildPythonPackage (finalAttrs: {
  pname = "pluggy";
  version = "0.13.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-FbKs3mZlYeEpjXG1IwB+1zZN4HApIZtgTPgIv6HHZbA=";
  };

  checkPhase = ''
    py.test
  '';

  # To prevent infinite recursion with pytest
  doCheck = false;

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [ importlib-metadata ];

  meta = {
    description = "Plugin and hook calling mechanisms for Python";
    homepage = "https://github.com/pytest-dev/pluggy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
