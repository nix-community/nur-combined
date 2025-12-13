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
  version = "0-unstable-2025-11-11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "furechan";
    repo = "mintalib";
    rev = "591a03a58a89b325249c1fb3431f54704eacc9c6";
    hash = "sha256-bu+j0QE92ZweMrmEvlrxOOgRPJJJhkvnc4myXNQt5XU=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    pandas
  ];

  optional-dependencies = {
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
