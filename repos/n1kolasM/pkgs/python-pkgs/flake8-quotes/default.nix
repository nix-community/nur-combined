{ lib, buildPythonPackage, fetchPypi
, flake8 }:
buildPythonPackage rec {
  pname = "flake8-quotes";
  version = "2.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1z4b27mmfm8k5b851c1y0p9zkdk2rwcp1gci4x6g199cr4q5v88i";
  };

  propagatedBuildInputs = [ flake8 ];
  doCheck = false;

  meta = with lib; {
    description = "Flake8 lint for quotes.";
    homepage = https://pypi.org/project/flake8-quotes;
    license = licenses.mit;
  };
}

