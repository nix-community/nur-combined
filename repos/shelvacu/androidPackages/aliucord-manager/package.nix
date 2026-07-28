{
  fetchFromGitHub,
  buildGradleAndroidPackage,
  gradle_9,
}:
buildGradleAndroidPackage rec {
  pname = "aliucord-manager";
  version = "1.3.0";
  applicationId = "com.aliucord.manager";

  src = fetchFromGitHub {
    owner = "aliucord";
    repo = "manager";
    tag = "v${version}";
    hash = "sha256-o49rqEBcOnKKbfSSq/bUeKFjPLYpBqD5eUhnIh/KE0M=";
  };

  patches = [
    ./no-git.patch
    ./no-sign.patch
  ];

  postPatch = ''
    sed -i 's/val gitCurrentBranch =.*/val gitCurrentBranch = "${src.tag}"/' app/build.gradle.kts
    sed -i 's/val gitLatestCommit =.*/val gitLatestCommit = "unknown"/' app/build.gradle.kts
    sed -i 's/val gitHasHasLocalChanges =.*/val gitHasHasLocalChanges = false/' app/build.gradle.kts
  '';

  sdkVersions = [ "36" ];

  gradle = gradle_9;

  lockFile = ./gradle.lock;

  env.RELEASE = "true";

  gradleBuildTask = ":app:packageRelease";

  enableParallelBuilding = false;
}
