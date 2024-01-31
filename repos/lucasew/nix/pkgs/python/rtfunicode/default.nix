{ buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "rtfunicode";
  version = "2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-l9LoYP1Kuq4t5d8eWbsYuFugyuv0DFPejdt57I2IRAE=";
  };

  doCheck = false; # pypi version doesn't ship with tests

  pythonImportsCheck = ["rtfunicode"];

  propagatedBuildInputs = [ ];
}
