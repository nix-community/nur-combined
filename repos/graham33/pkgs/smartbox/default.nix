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
  version = "0.0.6";

  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "v${version}";
    sha256 = "1kvpsjp4pwhpsv682fgsnfaph4ckklagnq39f1jv4naxnrlvqf78";
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
    # TODO: maintainer
    #maintainers = with maintainers; [ graham33 ];
  };
}
