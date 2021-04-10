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
  version = "0.8.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "00qv3qhrlad90v48fxhdvm3jzram25jchfn29cyq22nncr2y4qj5";
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
