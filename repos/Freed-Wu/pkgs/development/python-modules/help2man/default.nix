{ mySources
, python3
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.help2man) pname version src;
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    jinja2
  ];
  nativeCheckInputs = [
    setuptools
    shtab
  ];
  pythonImportsCheck = [
    "help2man"
  ];
}
