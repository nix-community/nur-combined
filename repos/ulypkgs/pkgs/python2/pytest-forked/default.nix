{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-forked";
  version = "1.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aqmsfgCtGlOcQb7G0hARMy3mcek4x2NzeOyXECBON8o=";
  };

  pyproject = true;

  dependencies = [ pytest ];

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # Do not function
  doCheck = false;

  setupHook = ./setup-hook.sh;

  meta = {
    changelog = "https://github.com/pytest-dev/pytest-forked/blob/master/CHANGELOG.rst";
    description = "Run tests in isolated forked subprocesses";
    homepage = "https://github.com/pytest-dev/pytest-forked";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
