{ lib
, stdenv
, javaVersion
, src
, version
, buildGraalvmProduct
}:

buildGraalvmProduct rec {
  inherit src javaVersion version;
  product = "python-installable-svm";

  graalvmPhases.installCheckPhase = ''
    echo "Testing GraalPython"
    $out/bin/graalpy -c 'print(1 + 1)'
    echo '1 + 1' | $out/bin/graalpy
  '';
}
