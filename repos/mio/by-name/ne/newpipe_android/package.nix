{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_9,
  jdk21,
  androidenv,
  android-translation-layer_patched,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  writeText,
}:

let
  # AGP 9.2 pulls Build-Tools 36; keep 37 available for compileSdk 37.
  buildToolsVersion = "36.0.0";
  androidComposition = androidenv.composeAndroidPackages {
    cmdLineToolsVersion = "latest";
    platformVersions = [
      "35"
      "37"
    ];
    buildToolsVersions = [
      buildToolsVersion
      "37.0.0"
    ];
    includeNDK = false;
    includeEmulator = false;
    includeSystemImages = false;
    includeSources = false;
  };
  androidSdk = androidComposition.androidsdk;
  androidSdkRoot = "${androidSdk}/libexec/android-sdk";
  aapt2 = "${androidSdkRoot}/build-tools/${buildToolsVersion}/aapt2";
  gradle = gradle_9.override { java = jdk21; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "newpipe-android";
  version = "0.29.1";

  src = fetchFromGitHub {
    owner = "TeamNewPipe";
    repo = "NewPipe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pzwqMrDZKN4zmmorRK1jN1Wzg4OVZ5zDtAjIEDLoAnY=";
  };

  patches = [
    ./0001-android-only-skip-desktop-ios-and-git.patch
  ];

  postPatch = ''
    # Configuration cache is flaky under the Gradle MITM proxy.
    sed -i 's/org.gradle.configuration-cache=true/org.gradle.configuration-cache=false/' gradle.properties

    printf '%s\n' \
      'sdk.dir=${androidSdkRoot}' \
      'android.aapt2FromMavenOverride=${aapt2}' \
      > local.properties

    echo "android.aapt2FromMavenOverride=${aapt2}" >> gradle.properties
  '';

  nativeBuildInputs = [
    copyDesktopItems
    gradle
    jdk21
    makeWrapper
  ];

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    pkg = finalAttrs.finalPackage;
    data = if stdenv.hostPlatform.isDarwin then ./deps-darwin.json else ./deps-linux.json;
    silent = false;
    useBwrap = false;
  };

  env = {
    JAVA_HOME = jdk21;
    ANDROID_HOME = androidSdkRoot;
    ANDROID_SDK_ROOT = androidSdkRoot;
  };

  gradleFlags = [
    "-Dorg.gradle.java.home=${jdk21}"
    "-Dfile.encoding=utf-8"
    "-Dorg.gradle.project.android.aapt2FromMavenOverride=${aapt2}"
  ];

  gradleBuildTask = ":app:assembleRelease";
  gradleUpdateTask = finalAttrs.gradleBuildTask;

  # Empty init script: reproducible archives break some Android Gradle Plugin tasks.
  gradleInitScript = writeText "empty-init-script.gradle" "";

  doCheck = false;

  # Gradle MITM + Android SDK license checks need loopback.
  __darwinAllowLocalNetworking = true;

  preBuild = ''
    export ANDROID_USER_HOME="$TMPDIR/android"
    export GRADLE_USER_HOME="$TMPDIR/gradle"
    mkdir -p "$ANDROID_USER_HOME" "$GRADLE_USER_HOME"
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 app/build/outputs/apk/release/*.apk \
      "$out/share/newpipe/NewPipe.apk"

    install -Dm644 ${./icon.png} \
      "$out/share/icons/hicolor/192x192/apps/newpipe.png"

    makeWrapper ${lib.getExe android-translation-layer_patched} "$out/bin/newpipe" \
      --run 'rm -rf "''${XDG_CACHE_HOME:-$HOME/.cache}/art"' \
      --set-default ATL_UGLY_ENABLE_WEBVIEW "" \
      --add-flags "--gapplication-app-id=org.schabi.newpipe" \
      --add-flags "$out/share/newpipe/NewPipe.apk"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "newpipe";
      desktopName = "NewPipe";
      comment = "Libre lightweight streaming frontend";
      exec = "newpipe";
      icon = "newpipe";
      categories = [
        "AudioVideo"
        "Video"
        "Player"
        "TV"
      ];
      startupWMClass = "org.schabi.newpipe";
    })
  ];

  meta = {
    description = "NewPipe Android app built from source, launched via patched Android Translation Layer";
    homepage = "https://newpipe.net";
    changelog = "https://github.com/TeamNewPipe/NewPipe/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "newpipe";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # gradle mitm cache
    ];
  };
})
