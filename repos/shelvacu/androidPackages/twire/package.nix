{ fetchFromGitHub, buildGradleAndroidPackage }:
buildGradleAndroidPackage {
  pname = "twire";
  version = "2.12.3-unstable-2026-07-09";
  applicationId = "com.perflyst.twire";

  src = fetchFromGitHub {
    owner = "twireapp";
    repo = "Twire";
    rev = "d9e8f39489e8c9099ec7d92adf22ef294be3107b";
    hash = "sha256-fobGobf3HDyIJtky4lTmQMBwaaKGBmC/f1g9nZGJEWE=";
  };

  postPatch = ''
    sed -i '/signingConfig = signingConfigs/ d' app/build.gradle.kts
  '';

  sdkVersions = [ "36" ];

  # AGP 8.9.1 defaults to build-tools 35.0.0
  extraComposeArgs = {
    buildToolsVersions = [
      "35.0.0"
      "36.0.0"
    ];
    ndkVersions = [ "25.0.8775105" ];
  };

  lockFile = ./gradle.lock;
}
