{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "priority";
  version = "1.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1gpzn9k9zgks0iw5wdmad9b4dry8haiz2sbp6gycpjkzdld9dhbb";
  };

  meta = with stdenv.lib; {
    description = "A pure-Python HTTP/2 Priority implementation";
    homepage = "https://python-hyper.org/priority";
    license = licenses.mit;
  };
}
