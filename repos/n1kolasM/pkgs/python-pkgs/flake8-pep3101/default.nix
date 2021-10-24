{ lib, buildPythonPackage, fetchPypi
, flake8, pytest, testfixtures }:
buildPythonPackage rec {
  pname = "flake8-pep3101";
  version = "1.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "04pm0y0r9vg8wyrswd4glh1l51f6lgwymgcfv7f2d0yy897fpqw6";
  };

  checkInputs = [ pytest testfixtures ];
  propagatedBuildInputs = [ flake8 ];
  
  meta = with lib; {
    description = "Checks for old string formatting.";
    homepage = https://pypi.org/project/flake8-pep3101;
    license = licenses.gpl2;
  };
}

