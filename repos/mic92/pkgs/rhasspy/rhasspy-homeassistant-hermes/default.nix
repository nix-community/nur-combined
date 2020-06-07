{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
, aiohttp
}:

buildPythonPackage rec {
  pname = "rhasspy-homeassistant-hermes";
  version = "0.1.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "668bf928502247a33be8ec1dd00a7534151e351d8a693d4b40651640c0aecc03";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
    aiohttp
  ];

  meta = with lib; {
    description = "MQTT service for handling intents using Home Assistant";
    homepage = "https://github.com/rhasspy/rhasspy-homeassistant-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
