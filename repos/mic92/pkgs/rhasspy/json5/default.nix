{ lib
, buildPythonPackage
, fetchPypi
, hypothesis
}:

buildPythonPackage rec {
  pname = "json5";
  version = "0.9.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "703cfee540790576b56a92e1c6aaa6c4b0d98971dc358ead83812aa4d06bdb96";
  };

  checkInputs = [
    hypothesis
  ];

  # requires files not in pypi
  doCheck = false;

  meta = with lib; {
    description = "A Python implementation of the JSON5 data format";
    homepage = "https://github.com/dpranke/pyjson5";
    license = licenses.asl20;
  };
}
