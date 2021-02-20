{ lib
, buildPythonPackage
, fetchPypi
, aiohttp
, authcaptureproxy
, backoff
, beautifulsoup4
, pytest-asyncio
, pytestCheckHook
, wrapt
}:

buildPythonPackage rec {
  pname = "teslajsonpy";
  version = "0.11.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0fnnzcjac06vkpjzkylykgqcfi5fkmz1jsv12ziscxqx6zpgmfrl";
  };

  # fix name used for beautifulsoup requirement
  # TODO: remove for 0.12.3
  patchPhase = "sed s/bs4/beautifulsoup4/ -i setup.py";

  propagatedBuildInputs = [
    aiohttp
    authcaptureproxy
    backoff
    beautifulsoup4
    wrapt
  ];

  checkInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  meta = with lib; {
    homepage = "https://github.com/zabuldon/teslajsonpy";
    license = licenses.asl20;
    description = "Async python module for Tesla API primarily for enabling Home-Assistant.";
    # TODO: maintainer
    #maintainers = with maintainers; [ graham33 ];
  };
}
