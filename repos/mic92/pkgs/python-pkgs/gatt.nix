{ lib
, buildPythonPackage
, fetchPypi
, dbus-python
, pygobject3
}:

buildPythonPackage rec {
  pname = "gatt";
  version = "0.2.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "626d9de24a178b6eaff78c31b0bd29f962681da7caf18eb20363f6288d014e3a";
  };

  propagatedBuildInputs = [ dbus-python pygobject3 ];

  meta = with lib; {
    description = "Bluetooth GATT SDK for Python";
    homepage = "https://github.com/getsenic/gatt-python";
    license = licenses.mit;
  };
}
