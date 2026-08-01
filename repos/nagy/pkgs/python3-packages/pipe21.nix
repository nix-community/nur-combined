{
  lib,
  python,
  fetchPypi,
  buildPythonApplication,
}:

buildPythonApplication rec {
  pname = "pipe21";
  version = "1.24.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-wr3MQYvzVJA73SgAgO/W0lFiL2htYVpKztxUmTWMq2k=";
  };

  nativeBuildInputs = [ python.pkgs.setuptools ];

  passthru.optional-dependencies = with python.pkgs; {
    dev = [
      bumpver
      hypothesis
      mkdocs
      mkdocs-material
      mypy
      pre-commit
      pytest
    ];
  };

  pythonImportsCheck = [ "pipe21" ];

  meta = {
    description = "Simple functional pipes";
    homepage = "https://pypi.org/project/pipe21/";
    maintainers = with lib.maintainers; [ nagy ];
  };
}
