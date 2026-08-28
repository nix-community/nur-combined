{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools-scm,
  pytest,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-runner";
  version = "5.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-lsfnPq17k+OIxdYUdw0rrmUm79mXdX01Q/4XtVeglCs=";
  };

  nativeBuildInputs = [
    setuptools-scm
    pytest
  ];

  postPatch = ''
    rm pytest.ini
  '';

  checkPhase = ''
    py.test tests
  '';

  # Fixture not found
  doCheck = false;

  meta = with lib; {
    description = "Invoke py.test as distutils command with dependency resolution";
    homepage = "https://github.com/pytest-dev/pytest-runner";
    license = licenses.mit;
  };
})
