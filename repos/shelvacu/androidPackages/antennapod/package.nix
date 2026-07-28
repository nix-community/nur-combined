{ fetchFromGitHub, buildGradleAndroidPackage }:
buildGradleAndroidPackage rec {
  pname = "antennapod";
  version = "3.11.0";
  applicationId = "de.danoeh.antennapod";

  src = fetchFromGitHub {
    owner = "antennapod";
    repo = "antennapod";
    tag = version;
    hash = "sha256-idx/+ybgD+HSGZQWt08rkksl2qHzbzLeg9CLkV/4USQ=";
  };

  postPatch = ''
    sed -i '/signingConfig signingConfigs/ d' app/build.gradle
  '';

  sdkVersions = [ "35" ];

  gradleBuildTask = ":app:assembleFreeRelease";

  lockFile = ./gradle.lock;

  extraLockData = {
    "com.google.guava:guava:32.1.3-jre" = {
      "guava-32.1.3-jre.jar" = {
        url = "https://repo.maven.apache.org/maven2/com/google/guava/guava/32.1.3-jre/guava-32.1.3-jre.jar";
        hash = "sha256-bU4rWhGKq2Lm5eKdGFoCJO7YLIXECsPTPPBKJww7N0Q=";
      };
    };
  };
}
