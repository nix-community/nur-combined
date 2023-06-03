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

  meta = with lib; {
    homepage = "https://help2man.readthedocs.io";
    description = "Convert --help and --version to man page";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.unix;
  };
}
