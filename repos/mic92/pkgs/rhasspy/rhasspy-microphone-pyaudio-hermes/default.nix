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
  version = "0.3.0";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-mlgGHl7PXxf2A5ol9x0hclPejoJQ72Rs4CWlXx5o0Ks=";
  };

  postPatch = ''
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

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
