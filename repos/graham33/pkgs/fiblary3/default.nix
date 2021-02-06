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

  propagatedBuildInputs = [
    jsonpatch
    netaddr
    prettytable
    python-dateutil
    requests
    six
    sphinx # TODO: propagated?
  ];

  meta = with lib; {
    homepage = "https://github.com/pbalogh/fiblary";
    license = licenses.asl20;
    description = "Home Center API Python Library";
    # TODO: maintainer
    #maintainers = with maintainers; [ graham33 ];
  };
}
