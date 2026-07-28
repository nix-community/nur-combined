{ fetchFromGitHub, buildGradleAndroidPackage }:
buildGradleAndroidPackage {
  name = "love";
  version = "12.0-unstable-2026-02-15";
  applicationId = "org.love2d.android";

  src = fetchFromGitHub {
    owner = "love2d";
    repo = "love-android";
    rev = "007d258cb477e51a08229f3d35179966da6e22d3";
    fetchSubmodules = true;
    hash = "sha256-zqy4n509X2OHnAlDg4c97CgDN0iIRimi28vz79GzClc=";
  };

  patches = [ ./prefer-vulkan.patch ];

  sdkVersions = [ "35" ];

  gradleBuildTask = "assembleNormalNoRecordRelease";

  extraComposeArgs = {
    ndkVersions = [ "27.1.12297006" ];
  };

  preConfigure = ''
    gradleFlagsArray+=("-Dorg.gradle.jvmargs=-Xmx2g -XX:MaxMetaspaceSize=512m")
  '';

  lockFile = ./gradle.lock;
}
