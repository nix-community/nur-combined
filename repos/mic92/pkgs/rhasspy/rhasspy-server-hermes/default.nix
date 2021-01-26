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
}:

buildPythonPackage rec {
  pname = "rhasspy-server-hermes";
  version = "2.5.5";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "0cb3d2b4afdd4c0412de2a5e56d37d980d195e6b";
    sha256 = "sha256-9SY6OvXH5VtDSPQyRlQe+stlY+ax9loNELx4KVpyiP8=";
  };

  postPatch = ''
    patchShebangs configure
    sed -i "s/swagger-ui-py==.*/swagger-ui-py/" requirements.txt
    sed -i "s/quart==.*/quart/" requirements.txt
    sed -i "s/aiohttp==.*/aiohttp/" requirements.txt
    sed -i "s/networkx==.*/networkx/" requirements.txt
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
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
