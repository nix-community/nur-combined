{ lib
, buildPythonPackage
, fetchPypi
, fetchpatch
, pythonOlder
, rhasspy-fuzzywuzzy
, rhasspy-hermes
, rhasspy-nlu
}:

buildPythonPackage rec {
  pname = "rhasspy-fuzzywuzzy-hermes";
  version = "0.6.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-ARJmvJ/Htvqip2V2QY0HYWeZ+NXOlgl4BOaxt5VgPmo=";
  };

  propagatedBuildInputs = [
    rhasspy-fuzzywuzzy
    rhasspy-hermes
    rhasspy-nlu
  ];

  postPatch = ''
    sed -i "s/networkx==.*/networkx/" requirements.txt
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  doCheck = false;

  meta = with lib; {
    description = "MQTT service for intent recognition with fuzzywuzzy using the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-fuzzywuzzy-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
