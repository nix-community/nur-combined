{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  prettytable,
  requests,
  black,
  build,
  flake8,
  isort,
  mypy,
  pre-commit,
  pytest,
  twine,
}:

buildPythonPackage rec {
  pname = "opensubtitlescom";
  version = "0.1.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dusking";
    repo = "opensubtitles-com";
    rev = "dc4cdf140a1e86a997c5fbcdc8eeb295699b627c";
    hash = "sha256-Prhk7p69VzIZvMHH+K4YMy9+zUVEglKWIOQZa/FiqTg=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    prettytable
    requests
  ];

  optional-dependencies = {
    dev = [
      black
      build
      flake8
      isort
      mypy
      pre-commit
      pytest
      twine
    ];
  };

  pythonImportsCheck = [
    "opensubtitlescom"
  ];

  meta = {
    description = "Python wrapper for the OpenSubtitles REST API";
    homepage = "https://github.com/dusking/opensubtitles-com";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
