{ mySources
, python3
, help2man
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.setuptools-generate) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    setuptools
    click
    help2man
    markdown-it-py
    setuptools
    shtab
    tomli
  ];
  pythonImportsCheck = [
    "setuptools_generate"
  ];
}
