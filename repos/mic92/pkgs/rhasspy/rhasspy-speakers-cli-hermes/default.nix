{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
, wavchunk
}:

buildPythonPackage rec {
  pname = "rhasspy-speakers-cli-hermes";
  version = "0.3.0";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-2ALTgggJhZ6eyrqb1ksPD2TcvkM2ve/9vI896BpGOoo=";
  };

  postPatch = ''
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  propagatedBuildInputs = [
    rhasspy-hermes wavchunk
  ];

  meta = with lib; {
    description = "MQTT service for Rhasspy audio output with external program using the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-speakers-cli-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
