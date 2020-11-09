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
  version = "2.5.3";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Toec8lVTdlx+aJhomENcB1vMKaf8M207as9U7c4265w=";
  };

  postPatch = ''
    patchShebangs configure
    sed -i "s/swagger-ui-py==.*/swagger-ui-py/" requirements.txt
    sed -i "s/quart==.*/quart/" requirements.txt
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
