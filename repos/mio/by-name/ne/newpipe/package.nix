{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_9,
  jdk21,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  writeText,
  desktopToDarwinBundle,
  # Runtime dependencies for the JVM desktop app
  libGL,
  libx11,
  libxext,
  libxrender,
  fontconfig,
  freetype,
}:

let
  gradle = gradle_9.override { java = jdk21; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "newpipe";
  version = "0.29.1";

  src = fetchFromGitHub {
    owner = "TeamNewPipe";
    repo = "NewPipe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pzwqMrDZKN4zmmorRK1jN1Wzg4OVZ5zDtAjIEDLoAnY=";
  };

  patches = [
    ./0001-desktop-only-remove-android-ios.patch
    ./0002-add-home-screen.patch
  ];

  postPatch = ''
    # Configuration cache is flaky under the Gradle MITM proxy.
    sed -i 's/org.gradle.configuration-cache=true/org.gradle.configuration-cache=false/' gradle.properties
  '';

  nativeBuildInputs = [
    copyDesktopItems
    gradle
    jdk21
    makeWrapper
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  env = {
    _JAVA_OPTIONS = "-Djava.net.preferIPv4Stack=true";
  };

  gradleFlags = [
    "-Dorg.gradle.java.home=${jdk21}"
    "-Dfile.encoding=utf-8"
  ];

  gradleBuildTask = ":desktopApp:packageUberJarForCurrentOS";
  gradleUpdateTask = finalAttrs.gradleBuildTask;

  # Empty init script: avoids potential issues with the Gradle MITM proxy.
  gradleInitScript = writeText "empty-init-script.gradle" "";

  preGradleUpdate = ''
    cat >> desktopApp/build.gradle.kts <<EOF
    dependencies {
        val skikoVersion = "0.144.6"
        runtimeOnly("org.jetbrains.skiko:skiko-awt-runtime-macos-x64:\$skikoVersion")
        runtimeOnly("org.jetbrains.skiko:skiko-awt-runtime-macos-arm64:\$skikoVersion")
        runtimeOnly("org.jetbrains.skiko:skiko-awt-runtime-linux-x64:\$skikoVersion")
        runtimeOnly("org.jetbrains.skiko:skiko-awt-runtime-windows-x64:\$skikoVersion")
    }
    EOF
  '';

  doCheck = false;
  __darwinAllowLocalNetworking = true;

  preBuild = ''
    export HOME="$TMPDIR"
    export ANDROID_USER_HOME="$TMPDIR/.android"
    mkdir -p "$ANDROID_USER_HOME"
    export _JAVA_OPTIONS="$_JAVA_OPTIONS -Duser.home=$TMPDIR"
  '';

  installPhase = ''
    runHook preInstall

    jarFile=$(find desktopApp/build/compose/jars -name "*.jar" | head -1)
    install -Dm644 "$jarFile" "$out/share/newpipe-native/newpipe-native.jar"

    install -Dm644 ${./icon.png} \
      "$out/share/icons/hicolor/192x192/apps/newpipe-native.png"

    makeWrapper ${jdk21}/bin/java "$out/bin/newpipe-native" \
      --add-flags "-jar $out/share/newpipe-native/newpipe-native.jar" \
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        --prefix LD_LIBRARY_PATH : "${
          lib.makeLibraryPath [
            libGL
            libx11
            libxext
            libxrender
            fontconfig
            freetype
          ]
        }"
      ''}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "newpipe-native";
      desktopName = "NewPipe (Native)";
      comment = "Libre lightweight streaming frontend — Compose Multiplatform desktop";
      exec = "newpipe-native";
      icon = "newpipe-native";
      categories = [
        "AudioVideo"
        "Video"
        "Player"
        "TV"
      ];
      startupWMClass = "newpipe-native";
    })
  ];

  meta = {
    description = "NewPipe Compose Multiplatform desktop app (native JVM build)";
    longDescription = ''
      NewPipe built from source as a native JVM desktop application using the
      Compose Multiplatform :desktopApp module. Unlike the ATL-based 'newpipe'
      package this runs directly on the JVM without Android emulation.
    '';
    homepage = "https://newpipe.net";
    changelog = "https://github.com/TeamNewPipe/NewPipe/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "newpipe-native";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # gradle mitm cache
    ];
  };
})
