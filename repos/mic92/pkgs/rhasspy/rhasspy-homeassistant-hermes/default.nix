{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, rhasspy-hermes
, aiohttp
}:

buildPythonPackage rec {
  pname = "rhasspy-homeassistant-hermes";
  version = "0.2.0";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "e4b0d9049d046c90b8862fe2dbca70a8917a5dff";
    sha256 = "sha256-du4mzX8DuKNK+6yH+5WpMB2v05Q8QDNW7U/8TExTeNI=";
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
