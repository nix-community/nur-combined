{
  mySources,
  python3,
  lib,
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.clipman) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    dbus-next
  ];
  nativeBuildInputs = [
    setuptools-scm
  ];
  pythonImportsCheck = [
    "clipman"
  ];

  meta = with lib; {
    homepage = "https://github.com/NikitaBeloglazov/clipman";
    description = "Python3 module for working with clipboard. Created because pyperclip is discontinued";
    license = licenses.mpl20;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
