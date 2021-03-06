{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, aiohttp
, rhasspy-hermes
, rhasspy-nlu
, rhasspy-silence
, fetchpatch
}:

buildPythonPackage rec {
  pname = "rhasspy-remote-http-hermes";
  version = "0.3.2";

  disabled = pythonOlder "3.7"; # requires python version >=3.7

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-zj5XUhGWutDlMlLv7ckz4NjqLNt6SNZmoLN2S61qCM4=";
  };

  postPatch = ''
    sed -i "s/aiohttp==.*/aiohttp/" requirements.txt
    sed -i "s/networkx==.*/networkx/" requirements.txt
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  propagatedBuildInputs = [
    aiohttp
    rhasspy-hermes
    rhasspy-nlu
    rhasspy-silence
  ];

  meta = with lib; {
    description = "MQTT service to use remote Rhasspy server with the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-remote-http-hermes";
    license = licenses.mit; # unable to map license to nix license format
    maintainers = [ maintainers.mic92 ];
  };
}
