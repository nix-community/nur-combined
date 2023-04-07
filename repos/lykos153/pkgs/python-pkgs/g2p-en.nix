{ lib
, buildPythonPackage
, fetchPypi
, numpy
, nltk
, inflect
, distance
}:

buildPythonPackage rec {
  pname = "g2p_en";
  version = "2.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-MuyxGYJ6OxDqjBGXJ29OpPRAcK5Wy70B8PJhh19Valg=";
  };

  propagatedBuildInputs = [ numpy nltk inflect distance ];

  meta = with lib; {
    description = "A Simple Python Module for English Grapheme To Phoneme Conversion";
    homepage = "https://github.com/Kyubyong/g2p";
    license = licenses.asl20;
  };
}
