{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pybase62";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "suminb";
    repo = "base62";
    tag = "v${version}";
    hash = "sha256-7N/SGJAVwJOy1ObijA2s9XMrqMMb2SUMJaN72ITUrOM=";
  };

  build-system = [
    setuptools
  ];

  pythonImportsCheck = [
    "base62"
  ];

  meta = {
    description = "Python module for base62 encoding";
    homepage = "https://github.com/suminb/base62";
    license = lib.licenses.bsd2WithViews;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "pybase62";
  };
}
