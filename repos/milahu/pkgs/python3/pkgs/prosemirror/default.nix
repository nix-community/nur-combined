{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, setuptools-scm
, cssselect
, lxml
, typing-extensions
, codecov
, coverage
, lxml-stubs
, mypy
, pytest
, pytest-cov
, ruff
}:

buildPythonPackage rec {
  pname = "prosemirror";
  version = "0.5.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AwhPJHPDuuQW7NlUs7KL0SLTAH9F+E8RzRbsRnHraiI=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cssselect
    lxml
    typing-extensions
  ];

  optional-dependencies = {
    dev = [
      codecov
      coverage
      lxml-stubs
      mypy
      pytest
      pytest-cov
      ruff
    ];
  };

  pythonImportsCheck = [ "prosemirror" ];

  meta = {
    description = "Python implementation of core ProseMirror modules for collaborative editing";
    homepage = "https://pypi.org/project/prosemirror";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
  };
}
