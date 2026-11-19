{
  fetchFromGitHub,
  buildGradleAndroidPackage,
  gradle-packages,
  jdk21_headless,
}:
let
  jdk = jdk21_headless;
  gradle = gradle-packages.mkGradle {
    version = "9.7.0";
    hash = "sha256-hPu6Rcf0xkq8d0YOHAD1Qen5YOPH7SU48e3hnqzYc64=";
    defaultJava = jdk;
  };
in
buildGradleAndroidPackage rec {
  pname = "k9mail";
  version = "25.0";
  applicationId = "com.fsck.k9.vacu";

  src = fetchFromGitHub {
    owner = "thunderbird";
    repo = "thunderbird-android";
    tag = "K9MAIL_${builtins.replaceStrings [ "." ] [ "_" ] version}";
    hash = "sha256-r6apw3cQkGdj6FQTATHE/7uNRFz5XXqex2l/tXpQvIY=";
  };

  patches = [ ./catch-all.patch ];

  # gradle2nix's init script is incompatible with isolated projects
  postPatch = ''
    substituteInPlace gradle.properties \
      --replace-fail org.gradle.unsafe.isolated-projects=true org.gradle.unsafe.isolated-projects=false \
      --replace-fail org.gradle.configuration-cache=true org.gradle.configuration-cache=false \
      --replace-quiet -Xmx10g -Xmx5g

    # installable alongside upstream K-9
    substituteInPlace app-k9mail/build.gradle.kts \
      --replace-fail 'applicationId = "com.fsck.k9"' 'applicationId = "${applicationId}"'
    sed -i 's|<string name="app_name">.*</string>|<string name="app_name">K-9 Mail (vacu)</string>|' \
      app-k9mail/src/main/res/values*/strings.xml
  '';

  inherit jdk gradle;
  sdkVersions = [
    "36"
    "37"
  ];

  subprojectName = "app-k9mail";
  gradleBuildTask = ":app-k9mail:assembleFossRelease";

  lockFile = ./gradle.lock;
}
