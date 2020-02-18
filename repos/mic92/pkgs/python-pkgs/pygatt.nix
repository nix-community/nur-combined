{ lib
, buildPythonPackage
, fetchPypi
, coverage
, nose
, pyserial
, pexpect
, enum-compat
}:

buildPythonPackage rec {
  pname = "pygatt";
  version = "4.0.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "7f4e0ec72f03533a3ef5fdd532f08d30ab7149213495e531d0f6580e9fcb1a7d";
  };

  buildInputs = [
    coverage
    nose
  ];

  propagatedBuildInputs = [
    pyserial
    pexpect
    enum-compat
  ];

  meta = with lib; {
    description = "Python Bluetooth LE (Low Energy) and GATT Library";
    homepage = https://github.com/peplin/pygatt;
    license = licenses.asl20;
    # maintainers = [ maintainers. ];
  };
}
