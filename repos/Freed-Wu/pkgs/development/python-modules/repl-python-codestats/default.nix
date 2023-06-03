{ mySources
, python3
, repl-python-wakatime
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.repl-python-codestats) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    setuptools
    repl-python-wakatime
  ];
  pythonImportsCheck = [
    "repl_python_codestats"
  ];

  meta = with lib; {
    homepage = "https://repl-python-codestats.readthedocs.io";
    description = "A codestats plugin for python REPLs";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.unix;
  };
}
