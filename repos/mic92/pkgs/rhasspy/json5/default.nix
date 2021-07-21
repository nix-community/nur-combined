{ lib
, buildPythonPackage
, fetchPypi
, hypothesis
}:

buildPythonPackage rec {
  pname = "json5";
  version = "0.9.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-kXWtG8JI4iu42VqOjXZZWL8ACP7y/oq6tbwE4PGsgwI=";
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
