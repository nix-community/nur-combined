{ lib
, buildPythonPackage
, fetchPypi
, pkgs
, numpy
}:

buildPythonPackage rec {
  # binary release only for windows + mac
  pname = "sox";
  version = "1.4.1";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sPLRNpJFC4ic0/ZhJ+lvgBlC7CqsW7IWU9/RUODXEFU=";
  };
  nativeBuildInputs = [
    #pkgs.sox
  ];
  propagatedBuildInputs = ([
    pkgs.sox
    numpy
  ]);
  meta = with lib; {
    homepage = "https://github.com/rabitt/pysox";
    description = "Python wrapper around SoX";
    license = licenses.bsd3;
  };
  doCheck = false; # AttributeError: module 'sox' has no attribute 'version'
}
