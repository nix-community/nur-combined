{ lib
, buildPythonPackage
, aiohttp
, click
, fetchFromGitHub
, freezegun
, isPy3k
, pytest
, pytest-asyncio
, pytest-mock
, pytest-randomly
, pytestCheckHook
, python-socketio_4
, pyyaml
, requests
, requests-mock
, websocket_client
}:

buildPythonPackage rec {
  pname = "smartbox";
  version = "0.3.0-pree692716";

  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    #rev = "v${version}";
    rev = "e692716d237ee801982a69152c93d3b4be34e905";
    sha256 = "sha256-4b6WNsCj5tXBuJpP6Ku2XkcPjUJR4HkgD3UB6pcup6A=";
  };

  propagatedBuildInputs = [ aiohttp
                            click
                            python-socketio_4
                            pyyaml
                            requests
                            websocket_client
                          ];

  checkInputs = [
    freezegun
    pytest
    pytest-asyncio
    pytest-mock
    pytest-randomly
    pytestCheckHook
    requests-mock
  ];

  meta = with lib; {
    homepage = "https://github.com/graham33/smartbox";
    license = licenses.mit;
    description = "Python API to control heating 'smart boxes'.";
    maintainers = with maintainers; [ graham33 ];
  };
}
