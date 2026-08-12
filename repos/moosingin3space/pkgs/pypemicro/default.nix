{
  lib
, buildPythonPackage
, fetchPypi
}:
buildPythonPackage rec {
  version = "0.1.9";
  pname = "pypemicro";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-HouDBlqfokKhbdWWDCfaUJrqIEC5f+sSnVmsrRseFmU=";
  };
}