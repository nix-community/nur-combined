{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-datadir";
  version = "1.7.1";
  format = "pyproject";

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "gabrielcnr";
    repo = "pytest-datadir";
    tag = "v${version}";
    hash = "sha256-5u+rZlG3r2o+GZUrbrRR3ZMQ+9/QXsh8mrlIZT9D0gE=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "pytest_datadir" ];

  meta = with lib; {
    description = "Pytest plugin for manipulating test data directories and files";
    homepage = "https://github.com/gabrielcnr/pytest-datadir";
    changelog = "https://github.com/gabrielcnr/pytest-datadir/blob/${src.tag}/CHANGELOG.rst";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
  };
}
