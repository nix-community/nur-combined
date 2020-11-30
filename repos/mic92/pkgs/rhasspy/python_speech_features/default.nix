{ lib
, pythonOlder
, buildPythonPackage
, fetchPypi
, numpy
, scipy
, mock
, pytest
}:

buildPythonPackage rec {
  pname = "python_speech_features";
  version = "0.6";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-oK6/dGRkvJKdwxYss2nX/5Z8OYxRIN31+0CmXwG5KxE=";
  };

  checkInputs = [ pytest mock ];

  propagatedBuildInputs = [
    numpy
    scipy
  ];

  meta = with lib; {
    description = "A ASGI Server based on Hyper libraries and inspired by Gunicorn";
    homepage = "https://github.com/jameslyons/python_speech_features";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
