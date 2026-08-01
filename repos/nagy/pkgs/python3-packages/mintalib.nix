{
  lib,
  setuptools,
  buildPythonPackage,
  fetchFromGitHub,
  numpy,
  pandas,
  polars,
}:

buildPythonPackage rec {
  pname = "mintalib";
  version = "0-unstable-2026-07-31";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "furechan";
    repo = "mintalib";
    rev = "f19f7b531c08169e4f1fa42d9f40d461da650dd3";
    hash = "sha256-vYfmm8q8DzifkRHcCOVDuBLhNpNK5o09lvunhphcBqs=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
  ];

  optional-dependencies = {
    pandas = [
      pandas
    ];
    polars = [
      polars
    ];
  };

  pythonImportsCheck = [
    "mintalib"
  ];

  meta = {
    description = "Minimal Technical Analysis Library for Python";
    homepage = "https://github.com/furechan/mintalib";
    changelog = "https://github.com/furechan/mintalib/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
