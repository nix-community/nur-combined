# generate gradle.lock lockfile for grpc-java-src

/*
FIXME
> Task :grpc-compiler:linkJava_pluginExecutable FAILED
/nix/store/s40y31bdn82sj6daaxid1bn3p7la03lv-binutils-2.43.1/bin/ld: cannot find -lprotoc: No such file or directory
/nix/store/s40y31bdn82sj6daaxid1bn3p7la03lv-binutils-2.43.1/bin/ld: cannot find -lprotobuf: No such file or directory
collect2: error: ld returned 1 exit status

https://github.com/grpc/grpc-java/issues/11475
*/

{ lib
, grpc-java-src
, stdenv
, jre
, gradle2nix
, fetchurl
, fetchFromGitHub
, protobuf
}:

# no. gradle requires network access to download plugin -> outputHash (fixed output derivation)
# Plugin [id: 'com.google.osdetector', version: '1.7.3', apply: false] was not found in any of the following sources:
/*
let
  gradle-dist = fetchurl {
    #url = "https://services.gradle.org/distributions/gradle-8.6-bin.zip";
    url = "https://services.gradle.org/distributions/gradle-8.13-bin.zip";
    hash = "sha256-IPGxF2I3JUpvwgTYQ0GW+hGkz7OHVnUZxhVW6HEK7Xg=";
  };
in
*/

stdenv.mkDerivation rec {
  pname = "grpc-java-lockfile";
  inherit (grpc-java-src) version src;

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "";

  # fix: C++ versions less than C++14 are not supported.
  CXXFLAGS = [ "-std=c++17" ];

  nativeBuildInputs = [
    jre # for gradle2nix
    gradle2nix
    protobuf
  ];

  buildInputs = [
    protobuf
  ];

  # gradle2nix --gradle-dist=file://${gradle-dist}
  buildPhase = ''
    runHook preBuild
    echo skipAndroid=true >> gradle.properties
    gradle2nix
    runHook postBuild
  '';

  installPhase = ''
    cp gradle.lock $out
  '';
}
