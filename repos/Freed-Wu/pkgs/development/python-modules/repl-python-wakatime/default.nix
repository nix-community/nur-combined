{ mySources
, python3
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.repl-python-wakatime) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    setuptools
    ptpython
    ipython
  ];
  pythonImportsCheck = [
    "repl_python_wakatime"
  ];
}
