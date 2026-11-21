{
  lib,
  fetchFromGitHub,
  buildGradleAndroidPackage,
  gradle-packages,
  jdk21,
}:
buildGradleAndroidPackage rec {
  pname = "bitwarden";
  version = "2026.11.1";
  applicationId = "com.x8bit.bitwarden-fdroid";

  # AGP 9.4 needs gradle >= 9.6
  gradle =
    (gradle-packages.mkGradle {
      version = "9.8.0";
      hash = "sha256-uv1c6c+uoPvM/chDmhrEL71M2cidyamIIo2KJjmljmw=";
      defaultJava = jdk21;
    }).wrapped;

  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "android";
    tag = "v${version}-bwpm";
    hash = "sha256-ufibs9f98OR6C3K7Fyc9sOx9YsohiCiiL5tR/32W/qM=";
  };

  patches = [
    # otherwise it fails with:
    # Authentication scheme 'all'(Authentication) is not supported by protocol 'file'
    ./remove-githubpackages-credentials.patch
  ];

  # upstream CI sets these
  postPatch = ''
    sed -i -E \
      -e 's/^appVersionCode = ".*"$/appVersionCode = "${toString passthru.versionCode}"/' \
      -e 's/^appVersionName = ".*"$/appVersionName = "${version}"/' \
      gradle/libs.versions.toml
    grep -qx 'appVersionCode = "${toString passthru.versionCode}"' gradle/libs.versions.toml
    grep -qx 'appVersionName = "${version}"' gradle/libs.versions.toml
  '';

  sdkVersions = [
    "36"
    "37"
  ];

  gradleBuildFlags = [ "--write-locks" ];

  gradleBuildTask = ":app:assembleFdroidRelease";

  lockFile = ./gradle.lock;

  passthru = {
    vacuIncrement = 0;
    # YYYYMMDDXX
    versionCode =
      let
        split = map lib.toInt (lib.splitVersion version);
        year = builtins.elemAt split 0;
        month = builtins.elemAt split 1;
        day = builtins.elemAt split 2;
      in
      assert passthru.vacuIncrement < 100;
      (((year * 100 + month) * 100 + day) * 100) + passthru.vacuIncrement;
  };
}
