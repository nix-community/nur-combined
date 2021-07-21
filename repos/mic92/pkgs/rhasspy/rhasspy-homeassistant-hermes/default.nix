{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
, aiohttp
}:

buildPythonPackage rec {
  pname = "rhasspy-homeassistant-hermes";
  version = "0.2.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-e7l5sUlXUMeHoSAZRx1VW4ugi0bLuaFNQCgcWM0ImEA=";
  };

  postPatch = ''
    patchShebangs ./configure
    sed -i "s/aiohttp==.*/aiohttp/" requirements.txt
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

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
