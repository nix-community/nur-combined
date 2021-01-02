{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
, rhasspy-nlu
, fetchpatch
, aiohttp
}:

buildPythonPackage rec {
  pname = "rhasspy-rasa-nlu-hermes";
  version = "0.3.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-gffZ94wHSghNbEOsvnOc6LquPmm4VXSm5YRuFBJqaug=";
  };

  postPatch = ''
    sed -i "s/aiohttp==.*/aiohttp/" requirements.txt
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  propagatedBuildInputs = [
    aiohttp
    rhasspy-hermes
    rhasspy-nlu
  ];

  meta = with lib; {
    description = "MQTT service for natural language understanding in Rhasspy using Rasa NLU with the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-rasa-nlu-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
