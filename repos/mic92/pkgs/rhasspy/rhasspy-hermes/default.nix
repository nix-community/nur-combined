{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, paho-mqtt
, dataclasses-json
}:

buildPythonPackage rec {
  pname = "rhasspy-hermes";
  version = "0.6.1";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-q88NYl0UKcQgewVZ+xevv/G7Hdf+bbJyKT/OMssVRS0=";
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
