{
  python3Packages,
  fetchFromGitHub,
  lib,
}:
python3Packages.buildPythonPackage rec {
  pname = "pylint-qt";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pylint-dev";
    repo = "pylint-qt";
    tag = "v${version}";
    hash = "sha256-sj3/v0cwLlxwVW/zXZeRS0UZXhYUPINxvKyCnVKza88=";
  };

  pythonRelaxDeps = [
    "pylint-plugin-utils"
    "pylint"
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pylint-plugin-utils
  ];

  pythonImportsCheck = [ "pylint_qt" ];

  env.BUILD_README = true; # Enables more tests

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Pylint plugin for improving Qt code analysis (PyQt5, PyQt6, PySide2, PySide6)";
    homepage = "github.com/pylint-dev/pylint-qt";
    license = lib.licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
  };
}
