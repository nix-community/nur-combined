{ fetchFromGitHub, mkDerivation, ansi-terminal, base, directory, doctest, filepath
, megaparsec, optparse-applicative, prettyprinter, process
, raw-strings-qq, stdenv, tasty, tasty-hunit, text, yaml
}:
mkDerivation {
  pname = "mahlzeit";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "kmein";
    repo = "mahlzeit";
    rev = "954c0fb3f45815999bc65d003794af6a850b069c";
    sha256 = "046yrr40hjmxkjmwzcvmwb39fxx2v2i6hgdxrjfiwilzvhikarrg";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    ansi-terminal base directory filepath megaparsec prettyprinter text
    yaml
  ];
  executableHaskellDepends = [
    ansi-terminal base directory filepath optparse-applicative process
    text yaml
  ];
  testHaskellDepends = [
    base doctest megaparsec raw-strings-qq tasty tasty-hunit
  ];
  homepage = "https://github.com/kmein/mahlzeit";
  description = "Recipe toolkit";
  license = stdenv.lib.licenses.mit;
}
