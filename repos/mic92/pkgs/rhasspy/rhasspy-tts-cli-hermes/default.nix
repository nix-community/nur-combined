{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
, jinja2
}:

buildPythonPackage rec {
  pname = "rhasspy-tts-cli-hermes";
  version = "0.4.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-YfkYm5CnkZFiNYIC6DBr/E6dbMTzIRQoVF2O00EJqAo=";
  };
  postPatch = ''
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
    sed -i 's/Jinja2==.*/Jinja2/' requirements.txt
  '';

  propagatedBuildInputs = [
    rhasspy-hermes jinja2
  ];

  meta = with lib; {
    description = "MQTT service for text to speech with external program using the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-tts-cli-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
