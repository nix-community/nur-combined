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
, pytest-benchmark
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
  version = "2.0.0-beta.1";
  format = "pyproject";

  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "v${version}";
    sha256 = "0y3kwzdbh0798l1wkdj7zkjyscacw9x419qm23v3xa4zhaah9d0j";
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
    pytest-benchmark
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
