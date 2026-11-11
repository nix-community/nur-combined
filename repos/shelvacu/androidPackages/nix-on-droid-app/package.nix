{
  lib,
  fetchFromGitHub,
  buildGradleAndroidPackage,
  gradle-packages,
  jdk11_headless,
}:
let
  jdk = jdk11_headless;
  gradle = gradle-packages.mkGradle {
    version = "7.5";
    hash = "sha256-y4fyIsVYW9RoOK1Nt4RjpcXz0zbl4rmNx8DFhlJzUcI=";
    defaultJava = jdk;
  };
in
buildGradleAndroidPackage rec {
  pname = "nix-on-droid-app";
  version = "0.3.7-unstable-2025-06-17";
  applicationId = "com.termux.nix";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nix-on-droid-app";
    rev = "e87b6091bffa7b6eafb1b59cc7824f5692441cd0";
    hash = "sha256-E1f5zcSkfiVa71uuvRxQ+FveXGPD81K68U2N9QAhpro=";
  };

  patches = [ ./mouse-tracking-1003.patch ];

  inherit jdk gradle;
  sdkVersions = [ "30" ];
  extraComposeArgs = {
    buildToolsVersions = [
      "30.0.3"
      "33.0.2"
    ];
    ndkVersions = [
      "22.1.7171670"
      "23.1.7779620"
    ];
  };

  lockFile = "${src}/nix/gradle.lock";
  gradleBuildFlags = [ ":terminal-emulator:testReleaseUnitTest" ];

  meta = {
    description = "Nix-on-Droid terminal with DECSET 1003 mouse tracking";
    homepage = "https://github.com/nix-community/nix-on-droid-app";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
