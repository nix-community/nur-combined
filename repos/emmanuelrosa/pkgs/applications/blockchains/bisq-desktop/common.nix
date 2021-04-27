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
    sha256 = "0p7h0biffkj4vx547vpn33fa2500whnq864inxdmxf8l3zp3c4wz";
    leaveDotGit = true;
    fetchLFS = true;
  });

  jdk = openjdk11;
  grpc = callPackage ./grpc-java.nix { };

  gradle = (gradleGen.override {
    java = jdk;
  }).gradle_5_6;
}
