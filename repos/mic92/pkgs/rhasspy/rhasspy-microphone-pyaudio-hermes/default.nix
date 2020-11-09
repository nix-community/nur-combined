{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
, webrtcvad
, pyaudio
}:

buildPythonPackage rec {
  pname = "rhasspy-microphone-pyaudio-hermes";
  version = "0.2.0";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-73gPMvriGCo3l3cQDcQU4P1bq9t25webHPGj0O99elo=";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
    webrtcvad
    pyaudio
  ];

  meta = with lib; {
    description = "MQTT service for audio input from PyAudio using Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-microphone-pyaudio-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
