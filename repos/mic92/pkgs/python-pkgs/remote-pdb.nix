{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "remote-pdb";
  version = "1.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "00aicmlrw3q31s26h8549n71p75p1nr0jcv40fyx47axw96kdbk1";
  };

  meta = with stdenv.lib; {
    description = "Remote vanilla PDB (over TCP sockets) done right: no extras, proper handling around connection failures and CI";
    homepage = https://github.com/ionelmc/python-remote-pdb;
    license = licenses.bsd2;
  };
}
