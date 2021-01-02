{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
}:

buildPythonPackage rec {
  pname = "rhasspy-dialogue-hermes";
  version = "0.2.0";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-qMpMrmZ96dsd0wzCf2c9WzTX9+O7XyAL//Bpy8VYEAU=";
  };

  postPatch = ''
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  propagatedBuildInputs = [
    rhasspy-hermes
  ];

  meta = with lib; {
    description = "MQTT service for dialogue management using the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-dialogue-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
