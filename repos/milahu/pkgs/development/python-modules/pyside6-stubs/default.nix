{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  mypy,
  pyside6,
}:

buildPythonPackage rec {
  pname = "pyside6-stubs";
  version = "6.7.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "python-qt-tools";
    repo = "PySide6-stubs";
    rev = "VERSION_6_7_3_0";
    hash = "sha256-/0X5+5H3gRy6tP7U9Sbwi5P/uPNWnf93xQNKYHy9XQc=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    mypy
    pyside6
  ];

  pythonImportsCheck = [
    # "pyside6_stubs"
  ];

  meta = {
    description = "Stubs for Qt6 for Python/PySide6";
    homepage = "https://github.com/python-qt-tools/PySide6-stubs";
    changelog = "https://github.com/python-qt-tools/PySide6-stubs/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ ];
  };
}
