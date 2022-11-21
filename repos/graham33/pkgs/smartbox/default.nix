{ lib
, buildPythonPackage
, aiohttp
, click
, fetchFromGitHub
, freezegun
, isPy3k
, jq
, pytest
, pytest-asyncio
, pytest-mock
, pytest-randomly
, pytestCheckHook
, python-socketio_4
, pyyaml
, requests
, requests-mock
, types-requests
, websocket-client
}:

buildPythonPackage rec {
  pname = "smartbox";
  version = "1.2.0-pre+fa0d9e";
  format = "pyproject";

  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "fa0d9e8ff5f997086d30b41508efb0469945f50e";
    sha256 = "0fam89g392l4jlzhfnr6wwv7lf43hfmi0sbrprlwsk4n9nn7g7ad";
  };

  propagatedBuildInputs = [
    aiohttp
    click
    jq
    python-socketio_4
    pyyaml
    requests
    websocket-client
  ];

  checkInputs = [
    freezegun
    pytest
    pytest-asyncio
    pytest-mock
    pytest-randomly
    pytestCheckHook
    requests-mock
    types-requests
  ];

  meta = with lib; {
    homepage = "https://github.com/graham33/smartbox";
    license = licenses.mit;
    description = "Python API to control heating 'smart boxes'.";
    maintainers = with maintainers; [ graham33 ];
  };
}
