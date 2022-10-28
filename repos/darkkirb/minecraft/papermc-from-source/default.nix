{
  stdenv,
  callPackage,
  gradle,
  openjdk_headless,
  git,
}: let
  src = callPackage ./source.nix {};
  deps = callPackage ./deps.nix {};
in
  stdenv.mkDerivation {
    pname = "papermc";
    version = src.passthru.source.date;
    inherit src;
    nativeBuildInputs = [
      gradle
      openjdk_headless
      git
    ];
    patchPhase = ''
      sed -i 's#mavenCentral..#maven("${deps}/maven")#g' build.gradle.kts
      sed -i 's#gradlePluginPortal..#maven("${deps}/maven")#g' settings.gradle.kts
    '';
    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d)
      gradle --offline --no-daemon --debug -Dorg.gradle.java.home=${openjdk_headless} applyPatches
      gradle --offline --no-daemon --info -Dorg.gradle.java.home=${openjdk_headless} createReobfBundlerJar
    '';
    installPhase = ''
      find build/lib
    '';
  }
