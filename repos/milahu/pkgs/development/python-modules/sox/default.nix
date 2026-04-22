{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "sox";
  version = "1.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "marl";
    repo = "pysox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6LPLCJJyPzh2UZSM41k1wpUwGG7H/+3stUUx1vR8aQA=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    typing-extensions
  ];

  pythonImportsCheck = [
    "sox"
  ];

  meta = {
    description = "Python wrapper around sox";
    homepage = "https://github.com/marl/pysox";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
  };
})
