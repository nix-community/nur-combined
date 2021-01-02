{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
, webrtcvad
}:

buildPythonPackage rec {
  pname = "rhasspy-microphone-cli-hermes";
  version = "0.2.0";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-4+bujodWZ4WjG8iEHgN+qS02PFuuzetNdKJu+QgTDyA=";
  };

  postPatch = ''
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  propagatedBuildInputs = [
    webrtcvad
    rhasspy-hermes
  ];

  meta = with lib; {
    description = "MQTT service for Rhasspy audio output with external program using the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-microphone-cli-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mit ];
  };
}
