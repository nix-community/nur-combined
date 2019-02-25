{ mkDerivation, base, blaze-builder, blaze-markup, blaze-svg
, bytestring, bytestring-builder, containers, criterion, deepseq
, directory, fetchgit, filepath, hspec, JuicyPixels, monads-tf, mtl
, NumInstances, optparse-applicative, parallel, parsec, random
, silently, snap-core, snap-server, stdenv, storable-endian, text
, transformers, unordered-containers, vector-space
}:
mkDerivation {
  pname = "implicitcad";
  version = "0.2.0";
  src = fetchgit {
    url = "https://github.com/colah/ImplicitCAD";
    sha256 = "1iwhhvz0a71jc5w9g66l6q7qmz927qbzjl4smsxzz9rkhyah24n7";
    rev = "c597ee39074120a969b99404ba7ff56b598c6d4f";
    fetchSubmodules = true;
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base blaze-builder blaze-markup blaze-svg bytestring
    bytestring-builder containers criterion deepseq directory filepath
    hspec JuicyPixels monads-tf NumInstances parallel parsec silently
    snap-core snap-server storable-endian text transformers
    unordered-containers vector-space
  ];
  executableHaskellDepends = [
    base blaze-builder blaze-markup blaze-svg bytestring containers
    criterion deepseq directory filepath JuicyPixels monads-tf
    optparse-applicative parallel parsec silently snap-core snap-server
    storable-endian text transformers vector-space
  ];
  testHaskellDepends = [ base containers hspec mtl parsec ];
  benchmarkHaskellDepends = [ base criterion parsec random ];
  postInstall = "rm $out/bin/Benchmark";
  homepage = "http://kalli1.faikvm.com/ImplicitCAD/Stable";
  description = "Warning: experimental package, might change at any time. Math-inspired programmatic 2&3D CAD, also known as extopenscad";
  license = stdenv.lib.licenses.agpl3;
}
