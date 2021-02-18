{ lib
, buildPythonPackage
, fetchPypi
, aiohttp
, authcaptureproxy
, backoff
, beautifulsoup4
, pytestCheckHook
, wrapt
}:

buildPythonPackage rec {
  pname = "teslajsonpy";
  version = "0.12.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0d6iyaxpr0jv4x697rzhzqvcdwg0dxzxqkp08874qgp1ckky7qbv";
  };

  propagatedBuildInputs = [
    aiohttp
    authcaptureproxy
    backoff
    beautifulsoup4
    wrapt
  ];

  checkInputs = [ pytestCheckHook ];

  # TODO: re-enable once resolved upstream
  disabledTests = [ "test_vehicle_device" ];

  meta = with lib; {
    homepage = "https://github.com/zabuldon/teslajsonpy";
    license = licenses.asl20;
    description = "Async python module for Tesla API primarily for enabling Home-Assistant.";
    # TODO: maintainer
    #maintainers = with maintainers; [ graham33 ];
  };
}
