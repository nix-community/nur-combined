{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, paho-mqtt
, dataclasses-json
}:

buildPythonPackage rec {
  pname = "rhasspy-hermes";
  version = "0.5.0";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-0fNlzJHkJ0X20AKuFuEx3njI5kCPTAXGL2cXa/GTSzo=";
  };

  postPatch = ''
    sed -i "s/dataclasses-json==.*/dataclasses-json/" requirements.txt
    sed -i -e "s/paho-mqtt==.*/paho-mqtt/" requirements.txt
  '';

  propagatedBuildInputs = [
    paho-mqtt
    dataclasses-json
  ];

  meta = with lib; {
    description = "Python classes for Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
