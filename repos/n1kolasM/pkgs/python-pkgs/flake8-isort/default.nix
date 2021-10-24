{ lib, buildPythonPackage, fetchPypi
, flake8, isort, testfixtures }:
buildPythonPackage rec {
  pname = "flake8-isort";
  version = "2.8.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1a9n9vqvywsvyiijcbwv54fly7976z55lwgf4gz3qc2a2lglsib4";
  };
  doCheck = false;
  propagatedBuildInputs = [ flake8 isort testfixtures ];

  meta = with lib; {
    description = "flake8 plugin that integrates isort.";
    homepage = https://pypi.org/project/flake8-isort;
    license = licenses.gpl2;
  };
}

