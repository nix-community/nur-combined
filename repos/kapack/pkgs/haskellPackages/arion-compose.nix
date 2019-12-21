{ mkDerivation, aeson, aeson-pretty, async, base, bytestring
, directory, fetchgit, hspec, lens, lens-aeson
, optparse-applicative, process, protolude, QuickCheck, stdenv
, temporary, text, unix
}:
mkDerivation {
  pname = "arion-compose";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/oar-team/arion";
    sha256 = "0ipw01w9banpy4qaycqm3c2sbvfn4la3yx6nm8hc6cg33x1k8xl3";
    rev = "14f5cf0de887b412837d67539d953fbd42398be4";
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
  license = stdenv.lib.licenses.asl20;
}
