{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pygubu";
  version = "0.40";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0hzgiqzs6sbbmmyis5jzxgdrsgcb90133x67hf5wxzj71qd5wxhx";
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
