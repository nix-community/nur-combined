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
  version = "0.1.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "3c51dd8acc4c334aaf6beaa6edff18a0de426e6076d649d2e008586e4e9274cd";
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
