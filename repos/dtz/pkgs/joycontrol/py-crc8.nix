{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "crc8";
  version = "0.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1bqlf7d7h6ylbin823c7dzh1838q4rh6wd2j13gkr0d3z5d91n3h";
  };

  meta = with lib; {
    homepage = "https://github.com/niccokunzmann/crc8";
    description = "Python library for calculating CRC8";
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
  };
}

