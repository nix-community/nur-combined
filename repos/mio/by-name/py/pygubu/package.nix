{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pygubu";
  version = "0.41.2";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-0KmmCet49YbU6H/16BjahVzk4ast07mH42Xy0Zvbp0s=";
  };

  propagatedBuildInputs = [
    python3Packages.tkinter
  ];

  doCheck = false; # Tests might require X11

  meta = with lib; {
    description = "A RAD tool for tkinter";
    homepage = "https://github.com/alejandroautalan/pygubu";
    license = licenses.bsd3;
  };
}
