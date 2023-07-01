{ lib
, python3
, fetchPypi
, buildPythonApplication
}:

buildPythonApplication rec {
  pname = "pipe21";
  version = "1.16.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-d/gferB3/pYdCoNmZItriwffE3qmAJFj6jHfJ3We1L8=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
  ];

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

  meta = with lib; {
    description = "Simple functional pipes";
    homepage = "https://pypi.org/project/pipe21/";
    license = with licenses; [ ];
    maintainers = with maintainers; [ nagy ];
  };
}
