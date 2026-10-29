{ mkDerivation
, lib
, base
, blaze-builder
, blaze-markup
, blaze-svg
, bytestring
, containers
, criterion
, data-default-class
, deepseq
, directory
, fetchgit
, filepath
, hedgehog
, hspec
, HUnit
, hw-hspec-hedgehog
, JuicyPixels
, lens
, linear
, mtl
, optparse-applicative
, parallel
, parsec
, prettyprinter
, QuickCheck
, random
, show-combinators
, text
}:
mkDerivation rec {
  pname = "implicitcad";
  version = "afd5f77f";
  src = fetchgit {
    url = "https://github.com/colah/ImplicitCAD";
    sha256 = "sha256-+mvu2PDg8vIK3VTBdEb8H/7eCccecodzb+sN9G/gGfY=";
    rev = "afd5f77f05c7fdf30141520e4a6014493f9e397f";
    fetchSubmodules = true;
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base
    blaze-builder
    blaze-markup
    blaze-svg
    bytestring
    containers
    data-default-class
    deepseq
    directory
    filepath
    JuicyPixels
    lens
    linear
    mtl
    parallel
    parsec
    prettyprinter
    random
    show-combinators
    text
  ];
  executableHaskellDepends = [
    base
    filepath
    optparse-applicative
    text
  ];
  testHaskellDepends = [
    base
    bytestring
    directory
    hedgehog
    hspec
    HUnit
    hw-hspec-hedgehog
    lens
    linear
    parsec
    QuickCheck
    text
  ];
  benchmarkHaskellDepends = [ base criterion linear parsec ];
  homepage = "http://implicitcad.org/";
  description = "Math-inspired programmatic 2D & 3D CAD system, also known as extopenscad";
  license = lib.licenses.agpl3Plus;
  mainProgram = "extopenscad";
}
