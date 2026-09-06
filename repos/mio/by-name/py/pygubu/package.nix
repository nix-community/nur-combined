{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pygubu";
  version = "0.42.1";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-7tsfbMoHyG7lkCcjbuzq7LnZUca3KyFW96CnUYVtOwM=";
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
