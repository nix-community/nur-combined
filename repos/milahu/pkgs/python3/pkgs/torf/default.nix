{ lib
, buildPythonPackage
, fetchFromGitHub
, fetchurl
, setuptools
, wheel
, flatbencode
, coverage
, flake8
, isort
, pytest
, pytest-cov
, pytest-httpserver
, pytest-mock
, pytest-xdist
, ruff
, tox
}:

buildPythonPackage rec {
  pname = "torf";
  version = "4.3.0";
  pyproject = true;

  src =
  if true then
  fetchurl {
    url = "https://github.com/rndusr/torf/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-gZQGi6mJrdH/2H6Mzvkke2XN5uSDzAXeeO2GiSJfUqo=";
  }
  else
  # error
  fetchFromGitHub {
    owner = "rndusr";
    repo = "torf";
    rev = "v${version}";
    hash = "";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    flatbencode
  ];

  passthru.optional-dependencies = {
    dev = [
      coverage
      flake8
      isort
      pytest
      pytest-cov
      pytest-httpserver
      pytest-mock
      pytest-xdist
      ruff
      tox
    ];
  };

  pythonImportsCheck = [ "torf" ];

  meta = with lib; {
    description = "Python module to create, parse and edit torrent files and magnet links";
    homepage = "https://github.com/rndusr/torf";
    #changelog = "https://github.com/rndusr/torf/blob/${src.rev}/CHANGELOG";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
