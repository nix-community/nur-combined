{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  pytest,
  ruff,
}:

buildPythonPackage rec {
  pname = "pytest-sphinx";
  version = "0.7.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "twmr";
    repo = "pytest-sphinx";
    rev = "v${version}";
    hash = "sha256-5c5m/7Na3/Tp0107AVoMd81OwOQH2u65otvN3d5IPRQ=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    pytest
  ];

  optional-dependencies = {
    lint = [
      ruff
    ];
  };

  pythonImportsCheck = [
    "pytest_sphinx"
  ];

  meta = {
    description = "Sphinx doctest plugin for pytest";
    homepage = "https://github.com/twmr/pytest-sphinx";
    changelog = "https://github.com/twmr/pytest-sphinx/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
  };
}
