
{ lib
, buildPythonPackage
, fetchPypi
, braceexpand
, numpy
, pyyaml
}:

buildPythonPackage rec {
  pname = "webdataset";
  version = "0.1.103";
  src = fetchPypi {
    inherit pname version;
    sha256 = "6kHpg5JL/CZ48r6nEgj7grIRbbwdyvIS+JLidI+SW18=";
  };
  propagatedBuildInputs = ([
    braceexpand
    numpy
    pyyaml
  ]);
  doCheck = false; # TODO
  meta = with lib; {
    homepage = "http://github.com/tmbdev/webdataset";
    description = "Record sequential storage for deep learning";
    license = licenses.mit;
  };
}
