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
  version = "0.7.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1iq39mig9c1nsyi9bvl8s5i8ydjpbi2dgcxkrf5pbjh1h1327qs7";
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
