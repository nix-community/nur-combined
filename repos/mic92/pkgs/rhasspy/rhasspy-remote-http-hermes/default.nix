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
  version = "0.4.0";

  disabled = pythonOlder "3.7"; # requires python version >=3.7

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-uSK+UPv1D/n+6qwMFyYgYKlzWQG1CWO6d1lPPt9Ob6Q=";
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
