{ mkDerivation, aeson, aeson-pretty, base, bytestring, conduit
, conduit-combinators, containers, fetchgit, Glob, hjsonschema
, hspec, neat-interpolation, optparse-applicative, protolude
, QuickCheck, quickcheck-instances, safe, scientific, semigroups
, stdenv, text, uniplate, unordered-containers, vector
}:
mkDerivation rec {
  pname = "jsons-to-schema";
  version = "0.1.0.0e";
  src = fetchgit {
    url = "https://github.com/garetht/jsons-to-schema";
    sha256 = "01sl310jmgwpljyywy5nwr8pws0bqvndgcz08wzp8pic23kdzg2j";
    rev = "v${version}";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson aeson-pretty base bytestring containers hjsonschema protolude
    QuickCheck safe scientific semigroups text unordered-containers
    vector
  ];
  executableHaskellDepends = [
    base bytestring conduit conduit-combinators Glob hjsonschema
    optparse-applicative protolude
  ];
  testHaskellDepends = [
    aeson aeson-pretty base bytestring containers hjsonschema hspec
    neat-interpolation protolude QuickCheck quickcheck-instances
    scientific text uniplate unordered-containers vector
  ];
  doHaddock = false;
  homepage = "https://github.com/garetht/jsons-to-schema/README.md";
  description = "JSON to JSON Schema";
  license = stdenv.lib.licenses.mit;
}
