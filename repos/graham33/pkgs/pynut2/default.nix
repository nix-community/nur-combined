{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "pynut2";
  version = "2.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "18jknigqiqjhy23ap1sn7l9ryshgn8nviyzg6x23v2p3yl329b70";
  };

  meta = with lib; {
    homepage = "https://github.com/mezz64/python-nut2";
    license = licenses.gpl3;
    description = "A Python abstraction class to access NUT servers.";
    maintainers = with maintainers; [ graham33 ];
  };
}
