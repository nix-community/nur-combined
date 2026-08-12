{ lib
, stdenv
, javaVersion
, src
, version
, buildGraalvmProduct
}:

buildGraalvmProduct rec {
  inherit src javaVersion version;
  product = "llvm-installable-svm";

  # TODO: improve this test
  graalvmPhases.installCheckPhase = ''
    echo "Testing llvm"
    $out/bin/lli --help
  '';
}
