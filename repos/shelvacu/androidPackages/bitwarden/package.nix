{
  fetchFromGitHub,
  buildGradleAndroidPackage,
  gradle_9,
}:
buildGradleAndroidPackage rec {
  pname = "bitwarden";
  version = "2026.6.0";
  applicationId = "com.x8bit.bitwarden-fdroid";

  gradle = gradle_9;

  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "android";
    tag = "v${version}-bwpm";
    hash = "sha256-JueJPhf74NJIJj0XWIuuNbJ57MYsZxX+kSGVBsk9rVM=";
  };

  patches = [
    # otherwise it fails with:
    # Authentication scheme 'all'(Authentication) is not supported by protocol 'file'
    ./remove-githubpackages-credentials.patch
  ];

  sdkVersions = [
    "36"
    "37"
  ];

  gradleBuildFlags = [ "--write-locks" ];

  gradleBuildTask = ":app:assembleFdroidRelease";

  lockFile = ./gradle.lock;
}
