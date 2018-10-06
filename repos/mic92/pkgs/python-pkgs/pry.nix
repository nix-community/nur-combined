{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "pry.py";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1lwxq9aq6iphsl5mhq543n9dv1z75g609vwgi0b3krd5b31laa06";
  };

  meta = with stdenv.lib; {
    description = "An interactive drop in shell for python, similar to binding.pry in ruby";
    homepage = https://github.com/Mic92/pry.py;
    license = licenses.mit;
  };
}
