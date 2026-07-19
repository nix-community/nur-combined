{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pygubu";
  version = "0.40.1";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-hLon3E3xKKGtvAhYdNgB6NeDYsBuZ87pLzsClnNefOM=";
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
