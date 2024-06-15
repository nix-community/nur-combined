{ lib
, buildPythonPackage
, aiohttp
, click
, fetchPypi
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
, setuptools
, types-requests
, websocket-client
}:

buildPythonPackage rec {
  pname = "smartbox";
  version = "2.0.0b2";
  format = "pyproject";

  disabled = !isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-9jA1rMofk+Ohr/KxnYWXeGHYj875wBJQWjbJpF51apI=";
  };

  nativeBuildInputs = [
    setuptools
  ];

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

  # TODO
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/graham33/smartbox";
    license = licenses.mit;
    description = "Python API to control heating 'smart boxes'.";
    maintainers = with maintainers; [ graham33 ];
  };
}
