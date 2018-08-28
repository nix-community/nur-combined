{ mkDerivation, base, bytestring, directory, fetchFromGitHub, filepath
, free, Glob, hpack, hspec, HUnit, mtl, parsec, pretty, process
, QuickCheck, split, stdenv, template-haskell, text, th-lift, time
}:
mkDerivation rec {
  pname = "language-docker";
  version = "5.0.1";
  src = fetchFromGitHub {
    owner = "hadolint";
    repo = pname;
    rev = version;
    sha256 = "1g5na74bqr33f83jwc377040lpdk8d2cl287f22arb80yz8179n5";
  };
  libraryHaskellDepends = [
    base bytestring free mtl parsec pretty split template-haskell text
    th-lift time
  ];
  libraryToolDepends = [ hpack ];
  testHaskellDepends = [
    base bytestring directory filepath free Glob hspec HUnit mtl parsec
    pretty process QuickCheck split template-haskell text th-lift time
  ];
  preConfigure = "hpack";
  # NOTE: Cowardly skip the examples.
  patches = [ ./examples-spec.patch ];
  homepage = "https://github.com/hadolint/language-docker#readme";
  description = "Dockerfile parser, pretty-printer and embedded DSL";
  license = stdenv.lib.licenses.gpl3;
  maintainers = with stdenv.lib.maintainers; [ yurrriq ];
}
