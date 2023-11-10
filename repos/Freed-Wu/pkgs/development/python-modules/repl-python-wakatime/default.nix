{ mySources
, python3
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.repl-python-wakatime) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  nativeBuildInputs = [
    setuptools-generate
    setuptools-scm
  ];
  pythonImportsCheck = [
    "repl_python_wakatime"
  ];

  meta = with lib; {
    homepage = "https://repl-python-wakatime.readthedocs.io";
    description = "Python REPL plugin for automatic time tracking and metrics generated from your programming activity";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
