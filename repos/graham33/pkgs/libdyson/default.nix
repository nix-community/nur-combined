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
  version = "0.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "04s9ib9xmsdgalgy66lc2h30k6w1k2194br7dl7w4j2z5phqah35";
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

  # TODO: requires pytest 6.2.0
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/shenxn/libdyson";
    license = licenses.asl20;
    description = "Dyson Python Library";
    # TODO: maintainer
    #maintainers = with maintainers; [ graham33 ];
  };
}
