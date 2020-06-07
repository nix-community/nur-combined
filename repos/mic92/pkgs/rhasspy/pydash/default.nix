{ lib
, buildPythonPackage
, fetchPypi
, pytest
, mock
}:

buildPythonPackage rec {
  pname = "pydash";
  version = "4.7.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "a7733886ab811e36510b44ff1de7ccc980327d701fb444a4b2ce395e6f4a4a87";
  };

  checkInputs = [
    pytest
    mock
  ];

  meta = with lib; {
    description = "The kitchen sink of Python utility libraries for doing stuff in a functional way. Based on the Lo-Dash Javascript library";
    homepage = https://github.com/dgilland/pydash;
    license = licenses.mit;
  };
}
