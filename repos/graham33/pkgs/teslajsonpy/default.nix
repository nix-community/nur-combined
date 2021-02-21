{ lib
, buildPythonPackage
, fetchPypi
, isPy3k
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
  version = "0.13.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0sz2zzlr6n62jhbff2fvg4vs8whzsnkhsvpdfpaa9ybdv4kdszxf";
  };

  disabled = !isPy3k;

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
