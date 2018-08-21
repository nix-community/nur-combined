{ fetchFromGitHub, callPackage }:
let
  # Same as upstream Sbtix but with minor patch
  sbtixDir = fetchFromGitHub {
      owner = "dtzWill";
      repo = "Sbtix";
      rev = "e51f7b028b737ce64a7ef9db8cf68421d52f9358";
      sha256 = "02q1nlbcdl5acycg36bqrvl6s8ia9civ9hkd9f6450zxqx06s512";
  };
in {
  sbtix = callPackage "${sbtixDir}/sbtix.nix" {};
  sbtix-tool = callPackage "${sbtixDir}/default.nix" {};
}

