{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, rhasspy-hermes
, webrtcvad
}:

buildPythonPackage rec {
  pname = "rhasspy-microphone-cli-hermes";
  version = "0.2.0";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "48b23d57fea4ba750d96197303446de896e712d6";
    sha256  = "sha256-RFl1ALe2Qz3NjWbXFmHo1brk+KjV8gHTzXOrzGQpAVY=";
  };

  postPatch = ''
    patchShebangs ./configure
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
