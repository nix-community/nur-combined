{ lib
, buildPythonPackage
, fetchPypi
, pytest
, pillow
, numpy
}:

buildPythonPackage rec {
  pname = "blurhash";
  version = "1.1.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "da56b163e5a816e4ad07172f5639287698e09d7f3dc38d18d9726d9c1dbc4cee";
  };

  # no tests in pypi
  doCheck = false;

  meta = with lib; {
    description = "Pure-Python implementation of the blurhash algorithm";
    homepage = https://github.com/halcy/blurhash-python;
    license = licenses.mit;
  };
}
