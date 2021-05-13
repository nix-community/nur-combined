{ lib
, buildPythonPackage
, fetchPypi
, python3Packages
}:

buildPythonPackage rec {
  pname = "baron";
  version = "0.9";

  src = fetchPypi {
    inherit version pname;
    extension = "tar.gz";
    sha256 = "b0589f32b91cf6dc450ea6a71b4a228c433ef8756b41fabf88815a3c2d392b3a";
  };

  propagatedBuildInputs = with python3Packages; [
    rply
  ];

  checkInputs = with python3Packages; [
    pytest
  ];

  meta = with lib; {
    description = "Full Syntax Tree for python to make writing refactoring code a realist task.";
    homepage = "https://github.com/PyCQA/baron";
    license = licenses.lgpl3Plus;
  };
}
