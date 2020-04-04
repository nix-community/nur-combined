{ lib, buildPythonPackage, fetchPypi, click, dnspython, mock, six }:

buildPythonPackage rec {
  pname = "mcstatus";
  version = "2.3.0";

  checkInputs = [ mock ];
  propagatedBuildInputs = [ click dnspython six ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "0giwwfj5p2pvs283wkvvn6vb66xq9xl8mqix0pds8nrpkbqsrflx";
  };

  patches = [ ./0001-Replace-dnspython3-with-dnspython.patch ];

  meta = {
    description = "Query Minecraft servers (with patches: 0001-Replace-dnspython3-with-dnspython.patch)";
    license = lib.licenses.asl20;
  };
}
