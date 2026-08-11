{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "treetable";
  version = "0.2.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "adefossez";
    repo = "treetable";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UNc0DeKcuSnTnMHdn3wS3smuuqGfPArnBCMCV7a3vMA=";
  };

  build-system = [
    setuptools
  ];

  pythonImportsCheck = [
    "treetable"
  ];

  meta = {
    description = "Print in ascii art a table with a tree-like structure";
    homepage = "https://github.com/adefossez/treetable";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ ];
  };
})
