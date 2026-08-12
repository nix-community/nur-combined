{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "rfc3339";
  version = "6.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "d53c3b5eefaef892b7240ba2a91fef012e86faa4d0a0ca782359c490e00ad4d0";
  };

  doCheck = false;  # no tests included
  pythonImportsCheck = [ "rfc3339" ];

  meta = with lib; {
    description = "Format dates according to the RFC 3339.";
    license = licenses.isc;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
