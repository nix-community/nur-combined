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
  version = "0.8.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "156yr7q166rzflbqj781rk7bs759dwhwv4d3czmnlka3laiswi3d";
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
