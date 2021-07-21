{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
}:

buildPythonPackage rec {
  pname = "rhasspy-dialogue-hermes";
  version = "0.6.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-lgZCvK8T1+Hw/KMSwnU56kWP/NAinfTwWueMpOBQld8=";
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
