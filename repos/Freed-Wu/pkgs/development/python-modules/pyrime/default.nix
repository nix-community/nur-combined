{
  mySources,
  python3,
  librime,
  pkg-config,
  stdenv,
  lib,
  autopxd,
}:

with python3.pkgs;

buildPythonPackage {
  inherit (mySources.pyrime) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    librime
    colorama
    ptpython
  ];
  nativeBuildInputs = [
    autopxd
    cython
    meson-python
    pkg-config
    stdenv.cc
  ];
  pythonImportsCheck = [
    "pyrime"
  ];

  meta = with lib; {
    homepage = "https://pyrime.readthedocs.io";
    description = "rime for python, attached to prompt-toolkit keybindings for some prompt-toolkit applications such as ptpython";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
