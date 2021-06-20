{ mkDerivation, lib, aeson, aeson-pretty, async, base, bytestring
, directory, fetchgit, hspec, lens, lens-aeson
, optparse-applicative, process, protolude, QuickCheck, stdenv
, temporary, text, unix
}:
mkDerivation {
  pname = "arion-compose";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/oar-team/arion";
    sha256 = "jHzcVhfBfG2zQGJ6ZCmE9J5qwlxMmWpQnqoBcttUOm8=";
    rev = "6e9b5b2c984bda256bfe10f462fe567a8c1ccca8";
    fetchSubmodules = true;
  };
  doCheck = false;
  isLibrary = true;
  isExecutable = true;
  enableSeparateDataOutput = true;
  libraryHaskellDepends = [
    aeson aeson-pretty async base bytestring directory lens lens-aeson
    process protolude temporary text unix
  ];
  executableHaskellDepends = [
    aeson aeson-pretty async base bytestring directory lens lens-aeson
    optparse-applicative process protolude temporary text unix
  ];
  testHaskellDepends = [
    aeson aeson-pretty async base bytestring directory hspec lens
    lens-aeson process protolude QuickCheck temporary text unix
  ];
  homepage = "https://github.com/hercules-ci/arion#readme";
  description = "Run docker-compose with help from Nix/NixOS";
  license = lib.licenses.asl20;
}
