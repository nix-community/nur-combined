{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
, webrtcvad
}:

buildPythonPackage rec {
  pname = "rhasspy-microphone-cli-hermes";
  version = "0.1.2";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "dca8ff242d505d77faeadaed3246567a41f066195a3004ea7ab36de806b598c0";
  };

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
