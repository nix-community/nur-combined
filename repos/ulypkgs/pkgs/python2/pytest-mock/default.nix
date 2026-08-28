{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  isPy3k,
  pytestCheckHook,
  mock,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-mock";
  version = "1.13.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-4kqRHslncwIuvMcDAFm1fNNIC1bU9dGbfDcOxjXmrtU=";
  };

  propagatedBuildInputs = lib.optional (!isPy3k) mock;

  nativeBuildInputs = [
    setuptools-scm
  ];

  checkInputs = [
    pytestCheckHook
  ];

  meta = with lib; {
    description = "Thin-wrapper around the mock package for easier use with py.test.";
    homepage = "https://github.com/pytest-dev/pytest-mock";
    license = licenses.mit;
    maintainers = with maintainers; [ nand0p ];
  };
})
