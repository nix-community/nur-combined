{ lib
, python3Packages
, mouseinfo
, python3-xlib
, pygetwindow
, pyrect
, pyscreeze
, pytweening
}:

python3Packages.buildPythonPackage rec {
  pname = "PyAutoGUI";
  version = "0.9.54";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-3R0p6P0RiUHLGT9031flxv+OklO5nHsE85z8afOuBLI=";
  };

  propagatedBuildInputs = with python3Packages; [
    pyrect
    mouseinfo
    pygetwindow
    pymsgbox
    pyscreeze
    python3-xlib
    pytweening
  ];

  doCheck = false;

  meta = with lib; {
    description = ''GUI automation Python module for human beings'';
    homepage = "https://github.com/asweigart/pyautogui";
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
