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
    sha256 = "0fjf066jixk30fr8xwfalwfnhqpr56yv0cccyypnx2qp9bi9svb2";
  };

  propagatedBuildInputs = [ dbus-python pygobject3 ];

  meta = with lib; {
    description = "Bluetooth GATT SDK for Python";
    homepage = "https://github.com/getsenic/gatt-python";
    license = licenses.mit;
  };
}
