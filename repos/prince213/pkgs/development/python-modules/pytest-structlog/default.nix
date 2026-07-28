{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  structlog,

  # nativeCheckInputs
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-structlog";
  version = "1.2";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "wimglenn";
    repo = "pytest-structlog";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4QzqlJStAF83lGgtfRB5cKGybmatWMQo0g9l0PZzfGw=";
  };

  build-system = [ setuptools ];

  dependencies = [ structlog ];

  pythonImportsCheck = [ "pytest_structlog" ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    description = "Structured logging assertions";
    homepage = "https://github.com/wimglenn/pytest-structlog";
    downloadPage = "https://github.com/wimglenn/pytest-structlog/releases";
    changelog = "https://github.com/wimglenn/pytest-structlog/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
