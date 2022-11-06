{ lib
, buildPythonPackage
, fetchPypi
, attrs
, cryptography
, paho-mqtt
, pytestCheckHook
, requests
, zeroconf
}:

buildPythonPackage rec {
  pname = "libdyson";
  version = "0.8.11";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-yvHzE6Qc46vinRdV5Xfg+A0AhWCh+yWOtDyrQ/xC2Xs=";
  };

  propagatedBuildInputs = [
    attrs
    cryptography
    paho-mqtt
    requests
    zeroconf
  ];

  checkInputs = [
    pytestCheckHook
  ];

  disabledTestPaths = [
    "tests/cloud/test_cloud_360_eye.py"
    "tests/cloud/test_dyson_account.py"
  ];

  meta = with lib; {
    homepage = "https://github.com/shenxn/libdyson";
    license = licenses.asl20;
    description = "Dyson Python Library";
    maintainers = with maintainers; [ graham33 ];
  };
}
