{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, paho-mqtt
, dataclasses-json
}:

buildPythonPackage rec {
  pname = "rhasspy-hermes";
  version = "0.2.1";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "cb9a6251e731755ab3a905a184dafb64ccd4f92adff6cdd774411e098ebe0b59";
  };

  postPatch = ''
    sed -i "s/dataclasses-json==.*/dataclasses-json/" requirements.txt
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
