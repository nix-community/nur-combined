{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
}:

buildPythonPackage rec {
  pname = "rhasspy-tts-cli-hermes";
  version = "0.2.0";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-3eqL03ydybX8ygd7oFWwDuyHzQZiNBBC+ocCk0Ov5TI=";
  };
  postPatch = ''
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

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
