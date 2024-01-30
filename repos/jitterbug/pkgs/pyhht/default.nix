{ lib
, fetchPypi
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  version = "0.1.0";
  pname = "pyhht";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1ecc495672f8851031d36156eac796a936e8b9726477e897376a21c449423d65";
  };

  propagatedBuildInputs = with python3Packages; [
    numpy
    scipy
    matplotlib
  ];


  patches = [
    patches/fix_scipy_import.patch
  ];

  meta = with lib; {
    description = "A Python module for the Hilbert Huang Transform.";
    homepage = "https://github.com/jaidevd/pyhht";
    license = licenses.mit; # src uses MIT, pypi uses BSD ??
    maintainers = [ "JuniorIsAJitterbug" ];
  };
}
