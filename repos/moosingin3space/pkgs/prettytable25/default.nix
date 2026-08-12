{
  lib
, buildPythonPackage
, fetchPypi
, setuptools
, setuptools-scm
, wcwidth
}:
buildPythonPackage rec {
  version = "2.5.0";
  pname = "prettytable";
  doCheck = false;
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-99pXumPVURbWXlrLFHv9+mDc7Mq/DWB9aBfuKIigXyw=";
  };

  buildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [
    wcwidth
  ];
}