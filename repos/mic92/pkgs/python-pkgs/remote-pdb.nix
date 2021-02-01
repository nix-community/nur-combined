{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "remote-pdb";
  version = "2.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0qpfjigsgnvr2sqha5jw25hk8pbd6qc2c1ll1y1bw8lvadpz6f5d";
  };

  meta = with lib; {
    description = "Remote vanilla PDB (over TCP sockets) done right: no extras, proper handling around connection failures and CI";
    homepage = "https://github.com/ionelmc/python-remote-pdb";
    license = licenses.bsd2;
  };
}
