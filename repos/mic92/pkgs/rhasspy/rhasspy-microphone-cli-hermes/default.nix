{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, rhasspy-hermes
, webrtcvad
, alsaTools
}:

buildPythonPackage rec {
  pname = "rhasspy-microphone-cli-hermes";
  version = "0.2.1";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "490e9b6abbdc24f85d3dcb5a41fb0c4b8870099d";
    sha256 = "sha256-9NQWewCFqCRaZQES2Zz/gES+HgXjtaaFF0LS0ySvn3s=";
  };

  postPatch = ''
    patchShebangs ./configure
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  makeWrapperArgs = [ "--prefix PATH : ${alsaTools}/bin" ];

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
