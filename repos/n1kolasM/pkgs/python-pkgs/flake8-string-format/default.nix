{ lib, buildPythonPackage, fetchPypi
, flake8 }:
buildPythonPackage rec {
  pname = "flake8-string-format";
  version = "0.2.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1w9ji233l9qlb3g87yhc01rf4vbxkgs5wicpi2bfshlj7l85ckbp";
  };

  propagatedBuildInputs = [ flake8 ];
  doCheck = false;
  
  meta = with lib; {
    description = "string format checker, plugin for flake8";
    homepage = https://pypi.org/project/flake8-string-format;
    license = licenses.mit;
  };
}

