{ stdenv, buildPythonPackage, fetchPypi
, pyserial, pyaes, ecdsa }:

buildPythonPackage rec {
  pname = "esptool";
  version = "2.6";

  propagatedBuildInputs = [
    pyserial
    pyaes
    ecdsa
  ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "0vd13ydq7y8msw68m1p3whq6sr2jrqy65l0b0cam26y2y2fm8bkf";
  };

  # unpackaged test dependencies
  doCheck = false;

  meta = with stdenv.lib; {
    description = "ESP8266 and ESP32 serial bootloader utility";
    homepage = https://github.com/espressif/esptool;
    license = licenses.gpl2;
  };
}
