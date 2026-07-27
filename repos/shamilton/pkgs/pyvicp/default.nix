{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "pyvicp";
  version = "1.1.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-DOqwEe6QSpsc+bfgFxlbo2kHGA6fvzkP5KcWwJ2DELs=";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools-scm
  ];
  buildInputs = with python3Packages; [ setuptools ];
  pyproject = true;
  # format = "setuptools";

  # doCheck = false;

  meta = with lib; {
    description = ''Pure Python client-side implementation of VICP network communications protocol used to control LeCroy Digital Oscilloscopes (DSOs)'';
    homepage = "https://github.com/asweigart/pyautogui";
    license = licenses.lgpl21;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
