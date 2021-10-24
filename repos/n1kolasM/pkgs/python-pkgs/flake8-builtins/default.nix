{ lib, buildPythonPackage, fetchPypi, flake8 }:
buildPythonPackage rec {
  pname = "flake8-builtins";
  version = "1.4.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0r1svv9sa6b4w6s46fak59hw6j4xp7ah1rsnf1rz6bhn37xiai64";
  };

  # Tests require missing in nixpkgs python package hypothesmith
  doCheck = false;
  propagatedBuildInputs = [ flake8 ];

  meta = with lib; {
    description = "Check for python builtins being used as variables or parameters.";
    homepage = https://pypi.org/project/flake8-builtins;
    license = licenses.gpl2;
  };
}

