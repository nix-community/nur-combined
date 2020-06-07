{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
}:

buildPythonPackage rec {
  pname = "rhasspy-tts-cli-hermes";
  version = "0.1.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "8581bf633be439835be1c73c8e58f1e7868ffa45801d5886503e6a9d17bdecd1";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
  ];

  meta = with lib; {
    description = "MQTT service for text to speech with external program using the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-tts-cli-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
