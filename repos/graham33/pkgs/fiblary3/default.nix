{ lib
, buildPythonPackage
, fetchPypi
, jsonpatch
, netaddr
, prettytable
, python-dateutil
, requests
, six
, sphinx
}:

buildPythonPackage rec {
  pname = "fiblary3";
  version = "0.1.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "ab666088d1996e1cc510ff91c9ff00ac14c7304d327d478ad948b3ea0c27668e";
  };

  nativeBuildInputs = [
    sphinx
  ];

  propagatedBuildInputs = [
    jsonpatch
    netaddr
    prettytable
    python-dateutil
    requests
    six
  ];

  meta = with lib; {
    homepage = "https://github.com/pbalogh77/fiblary";
    license = licenses.asl20;
    description = "Fibaro Home Center API Python Library";
    # TODO: maintainer
    #maintainers = with maintainers; [ graham33 ];
  };
}
