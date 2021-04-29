{ callPackage
, fetchFromGitHub
, openjdk11
, gradle
, gradleGen
}:
rec {
  pname = "bisq-desktop";
  version = "1.6.2";

  src = (fetchFromGitHub {
    owner = "bisq-network";
    repo = "bisq";
    rev = "v${version}";
    sha256 = "05w9f2aqvwlwxjylnbzc3mvi8mz1n0dv1938c589698pyfzfwhw8";
    leaveDotGit = true;
    fetchLFS = true;
  });

  jdk = openjdk11;
  grpc = callPackage ./grpc-java.nix { };

  gradle = (gradleGen.override {
    java = jdk;
  }).gradle_5_6;
}
