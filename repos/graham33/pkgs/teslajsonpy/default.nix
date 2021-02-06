{ lib
, buildPythonPackage
, fetchPypi
, aiohttp
, backoff
, beautifulsoup4
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
  patchPhase = "sed s/bs4/beautifulsoup4/ -i setup.py";

  propagatedBuildInputs = [
    aiohttp
    backoff
    beautifulsoup4
    wrapt
  ];

  checkInputs = [ pytestCheckHook ];

  # TODO: one test failure
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/zabuldon/teslajsonpy";
    license = licenses.asl20;
    description = "Async python module for Tesla API primarily for enabling Home-Assistant.";
    # TODO: maintainer
    #maintainers = with maintainers; [ graham33 ];
  };
}
