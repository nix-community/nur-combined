{
  mySources,
  python3,
  lib,
}:

with python3.pkgs;

buildPythonPackage {
  inherit (mySources.autopxd) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    click
    pycparser
  ];
  nativeBuildInputs = [
    setuptools
  ];
  pythonImportsCheck = [
    "autopxd"
  ];

  meta = with lib; {
    homepage = "https://github.com/elijahr/python-autopxd2";
    description = "generates .pxd files automatically from .h files";
    license = licenses.mit;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
