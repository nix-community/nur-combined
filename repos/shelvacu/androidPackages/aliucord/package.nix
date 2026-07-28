{
  fetchFromGitHub,
  buildGradleAndroidPackage,
  gradle_9,
}:
buildGradleAndroidPackage rec {
  pname = "aliucord";
  version = "2.9.5";
  applicationId = "com.aliucord";

  src = fetchFromGitHub {
    owner = "aliucord";
    repo = "aliucord";
    rev = "ae16d4bb24dd78360ff092446a9a2c654522aab2";
    hash = "sha256-o9t0CR22U5VHuGY0HdJYLgnOfR5baZnwCjWSSpo/C4Y=";
  };

  extraComposeArgs = {
    platformVersions = [
      "36"
      "35"
    ];
    buildToolsVersions = [
      "36.0.0"
      "35.0.0"
    ];
  };

  gradle = gradle_9;

  lockFile = ./gradle.lock;

  env.RELEASE = "true";

  # gradleBuildTask = ":Aliucord:assembleRelease";
  subprojectName = "Aliucord";

  enableParallelBuilding = false;
}
