{ lib
, buildPythonPackage
, fetchFromGitHub
, fetchPypi
, fetchpatch
, pythonOlder
, rhasspy-hermes
, rhasspy-profile
, rhasspy-nlu
, swagger-ui-py
, rhasspy-supervisor
, quart
, quart-cors
, multidict
}:

buildPythonPackage rec {
  pname = "rhasspy-server-hermes";
  version = "2.5.5";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "796ad413581431e99f1a58c884262b11ae0897d4";
    sha256 = "sha256-Kd30xi7sJOxmxg4ncsFES2lWVwo+kZgpHUlcI146xsg=";
  };

  postPatch = ''
    patchShebangs configure
    sed -i "s/swagger-ui-py==.*/swagger-ui-py/" requirements.txt
    sed -i "s/quart==.*/quart/" requirements.txt
    sed -i "s/aiohttp==.*/aiohttp/" requirements.txt
    sed -i "s/networkx==.*/networkx/" requirements.txt
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
    sed -i 's/multidict==.*/multidict/' requirements.txt
  '';

  propagatedBuildInputs = [
    rhasspy-hermes
    rhasspy-profile
    rhasspy-nlu
    swagger-ui-py
    rhasspy-supervisor
    quart
    quart-cors
  ];

  postInstall = ''
    mkdir -p $out/share/rhasspy
    cp -r templates $out/share/rhasspy/templates
    cp -r web $out/share/rhasspy/web
  '';

  doCheck = false;

  meta = with lib; {
    description = "Web server interface to Rhasspy with Hermes back-end";
    homepage = "https://github.com/rhasspy/rhasspy-server-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
