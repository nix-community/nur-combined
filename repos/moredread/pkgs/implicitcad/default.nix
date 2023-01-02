{ mkDerivation
, lib
, base
, blaze-builder
, blaze-markup
, blaze-svg
, bytestring
, bytestring-builder
, containers
, criterion
, deepseq
, directory
, fetchgit
, filepath
, hspec
, JuicyPixels
, monads-tf
, mtl
, NumInstances
, optparse-applicative
, parallel
, parsec
, random
, silently
, snap-core
, snap-server
, stdenv
, storable-endian
, text
, transformers
, unordered-containers
, vector-space
, hedgehog, hw-hspec-hedgehog, lens, linear, show-combinators
}:
mkDerivation rec {
  pname = "implicitcad";
  version = "0.4.0.0";
  src = fetchgit {
    url = "https://github.com/colah/ImplicitCAD";
    sha256 = "sha256-6y0I11SnKLLpgQHUt3w1gjvrN0Vgxej0J5VEFdLjijs=";
    rev = "v${version}";
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
    bytestring-builder
    containers
    criterion
    deepseq
    directory
    filepath
    hspec
    JuicyPixels
    monads-tf
    NumInstances
    parallel
    parsec
    silently
    snap-core
    snap-server
    storable-endian
    text
    transformers
    unordered-containers
    vector-space
    hedgehog
    hw-hspec-hedgehog
    lens
    linear
    show-combinators
  ];
  executableHaskellDepends = [
    base
    blaze-builder
    blaze-markup
    blaze-svg
    bytestring
    containers
    criterion
    deepseq
    directory
    filepath
    JuicyPixels
    monads-tf
    optparse-applicative
    parallel
    parsec
    silently
    snap-core
    snap-server
    storable-endian
    text
    transformers
    vector-space
    hedgehog
    hw-hspec-hedgehog
    lens
    linear
    show-combinators
  ];
  testHaskellDepends = [ base containers hspec mtl parsec ];
  benchmarkHaskellDepends = [ base criterion parsec random ];
  homepage = "http://kalli1.faikvm.com/ImplicitCAD/Stable";
  description = "Warning: experimental package, might change at any time. Math-inspired programmatic 2&3D CAD, also known as extopenscad";
  license = lib.licenses.agpl3;
}
