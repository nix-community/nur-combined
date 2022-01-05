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
  version = "0.5.0-pre";
  format = "pyproject";

  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    #rev = "v${version}";
    rev = "6825c48b29c38c5b85f6decdc0e00178056a86ae";
    sha256 = "sha256:17ipgpvv3ni6c4kss41nain0s2rpxivply0k5dx0p0jqdpgwlsyv";
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
