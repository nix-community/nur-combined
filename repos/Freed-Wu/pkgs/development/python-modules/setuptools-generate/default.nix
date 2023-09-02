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
    shtab
    tomli
  ];
  nativeBuildInputs = [
    setuptools-scm
  ];
  pythonImportsCheck = [
    "setuptools_generate"
  ];

  meta = with lib; {
    homepage = "https://setuptools-generate.readthedocs.io";
    description = "Generate shell completions and man page when building a python package";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
