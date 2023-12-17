{ lib
, stdenv
, javaVersion
, src
, version
, buildGraalvmProduct
}:

buildGraalvmProduct rec {
  inherit src javaVersion version;
  product = "js-installable-svm";

  graalvmPhases.installCheckPhase = ''
    echo "Testing GraalJS"
    echo '1 + 1' | $out/bin/js
  '';
}
