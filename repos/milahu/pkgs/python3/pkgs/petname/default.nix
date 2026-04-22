{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "petname";
  version = "2.9";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dustinkirkland";
    repo = "python-petname";
    rev = version;
    hash = "sha256-pXvEcZYeA4YMvlWouGVrMgAi4d4B8d0jkO+GjNlFhm4=";
  };

  build-system = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [
    "python_petname"
  ];

  meta = {
    description = "";
    homepage = "https://github.com/dustinkirkland/python-petname";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}
