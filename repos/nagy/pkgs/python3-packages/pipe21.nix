{
  lib,
  python3,
  fetchPypi,
  buildPythonApplication,
}:

buildPythonApplication rec {
  pname = "pipe21";
  version = "1.23.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-U4MFuujCggI64taGhLnFkgaHzYyg8o70H0H46EjklqM=";
  };

  nativeBuildInputs = [ python3.pkgs.setuptools ];

  passthru.optional-dependencies = with python3.pkgs; {
    dev = [
      autopep8
      black
      bumpver
      coveralls
      hypothesis
      mkdocs
      mkdocs-material
      pre-commit
      pytest
      pytest-cov
    ];
  };

  pythonImportsCheck = [ "pipe21" ];

  meta = {
    description = "Simple functional pipes";
    homepage = "https://pypi.org/project/pipe21/";
    maintainers = with lib.maintainers; [ nagy ];
  };
}
