{ lib
, buildPythonPackage
, fetchPypi
, netifaces
, paho-mqtt
, pycryptodome
, requests
}:

buildPythonPackage rec {
  pname = "libpurecool";
  version = "0.6.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1kwbinbg0i4fca1bpx6jwa1fiw71vg0xa89jhq4pmnl5cn9c8kqx";
  };

  propagatedBuildInputs = [
    netifaces
    paho-mqtt
    pycryptodome
    requests
  ];

  # TODO: import failure running tests
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/etheralm/libpurecool";
    license = licenses.asl20;
    description = "Dyson Pure Cool/Hot+Cool Link and 360 eye robot vacuum devices Python library";
    # TODO: maintainer
    #maintainers = with maintainers; [ graham33 ];
  };
}
