# generate gradle.lock lockfile for grpc-java-src

/*
FIXME
> Task :grpc-compiler:linkJava_pluginExecutable FAILED
/nix/store/s40y31bdn82sj6daaxid1bn3p7la03lv-binutils-2.43.1/bin/ld: cannot find -lprotoc: No such file or directory
/nix/store/s40y31bdn82sj6daaxid1bn3p7la03lv-binutils-2.43.1/bin/ld: cannot find -lprotobuf: No such file or directory
collect2: error: ld returned 1 exit status

https://github.com/grpc/grpc-java/issues/11475

-> downgrade to protobuf 3.19.1
*/

{ lib
, haveno
, stdenv
, jre
, gradle2nix
, fetchurl
, fetchFromGitHub
#, protobuf
# https://github.com/haveno-dex/haveno/issues/735
# FIXME no effect on lockfile
, gradleVersion ? "8.2.1"
}:

stdenv.mkDerivation rec {
  pname = "${haveno.pname}-lockfile";
  inherit (haveno) version src;

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  #outputHash = "sha256-xHgzWPN5IOJur/H5PrgFitWa8Y6teGdn+VxCdFuJ38Y=";
  outputHash = "";

  # fix: C++ versions less than C++14 are not supported.
  CXXFLAGS = [ "-std=c++17" ];

  nativeBuildInputs = [
    jre # for gradle2nix
    gradle2nix
#    protobuf
  ];

  buildInputs = [
#    protobuf
  ];

  # gradle2nix --gradle-dist=file://${gradle-dist}
  buildPhase = ''
    runHook preBuild
    #echo skipAndroid=true >> gradle.properties
    #gradle2nix --gradle-dist=https://services.gradle.org/distributions/gradle-${gradleVersion}-bin.zip
    #gradle2nix --gradle-wrapper=${gradleVersion}
    gradle2nix
    # show all deprecation warnings
    #gradle2nix -- --warning-mode all
    runHook postBuild
  '';

  installPhase = ''
    cp gradle.lock $out
  '';
}
