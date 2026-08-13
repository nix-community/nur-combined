{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_8,
  jdk21,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  cups,
  desktopToDarwinBundle,
  file,
  fontconfig,
  freetype,
  glib,
  gtk3,
  libGL,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxtst,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  wrapGAppsHook3,
  zlib,
}:

let
  jdk = jdk21;
  gradle = gradle_8.override { java = jdk; };

  # Compose native launcher + Skiko/JNA on Linux.
  runtimeLibs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    cups
    file
    fontconfig
    freetype
    glib
    gtk3
    libGL
    libx11
    libxcursor
    libxext
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxrender
    libxtst
    zlib
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "komi-store";
  version = "1.9.2";

  strictDeps = true;

  src = fetchFromGitHub {
    owner = "kurikomi-labs";
    repo = "komi-store";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oRGkXLoH8+bzy3NE2rdtW3qgqT2c+z2y0qmwosatAeg=";
  };

  # Desktop-only: upstream also targets Android (SDK not available in nixpkgs).
  patches = [
    # Compose Gradle plugin artifacts live on JetBrains Space.
    ./compose-repo.patch
    # Isolated build-logic included build has no pluginManagement.
    ./build-logic-pluginmanagement.patch
    ./disable-android-convention.patch
    ./disable-android-composeapp.patch
  ];

  nativeBuildInputs = [
    copyDesktopItems
    gradle
    jdk
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    wrapGAppsHook3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    desktopToDarwinBundle
  ];

  buildInputs = runtimeLibs;

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
    silent = false;
    useBwrap = false;
  };

  __darwinAllowLocalNetworking = true;

  env.JAVA_HOME = jdk;

  gradleFlags = [
    "-Dorg.gradle.java.home=${jdk}"
    "-Dfile.encoding=utf-8"
  ];

  gradleBuildTask = "composeApp:createDistributable";
  gradleUpdateTask = finalAttrs.gradleBuildTask;

  # currentOs only pulls host natives; also lock linux-arm64 + macOS artifacts.
  gradleUpdateScript = ''
    runHook preBuild
    runHook preGradleUpdate

    cat >> composeApp/build.gradle.kts <<'EOF'

    kotlin.sourceSets.named("jvmMain") {
        dependencies {
            val composeDesktop = libs.versions.compose.multiplatform.get()
            implementation("org.jetbrains.compose.desktop:desktop-jvm-linux-arm64:$composeDesktop")
            implementation("org.jetbrains.compose.desktop:desktop-jvm-macos-x64:$composeDesktop")
            implementation("org.jetbrains.compose.desktop:desktop-jvm-macos-arm64:$composeDesktop")
        }
    }
    EOF

    gradle ${finalAttrs.gradleBuildTask}

    runHook postGradleUpdate
  '';

  # Tests are Android-oriented and need an SDK.
  doCheck = false;

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/bin $out/libexec
    cp -a composeApp/build/compose/binaries/main/app/Komi-Store.app $out/libexec/
    makeWrapper $out/libexec/Komi-Store.app/Contents/MacOS/Komi-Store $out/bin/komi-store
    install -Dm644 composeApp/src/jvmMain/resources/logo/app_icon.png \
      $out/share/icons/hicolor/512x512/apps/komi-store.png
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/lib
    cp -a composeApp/build/compose/binaries/main/app/Komi-Store $out/lib/komi-store

    # Use nixpkgs JDK instead of the bundled runtime (already patchelf'd).
    rm -rf $out/lib/komi-store/lib/runtime
    ln -s ${jdk.home} $out/lib/komi-store/lib/runtime

    install -Dm644 composeApp/src/jvmMain/resources/logo/app_icon.png \
      $out/share/icons/hicolor/512x512/apps/komi-store.png
  ''
  + ''
    runHook postInstall
  '';

  # wrapGAppsHook3 + extra native search path for Skiko/JNA.
  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    makeWrapper $out/lib/komi-store/bin/Komi-Store $out/bin/komi-store \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "komi-store";
      exec = "komi-store";
      icon = "komi-store";
      desktopName = "Komi Store";
      genericName = "App Store";
      comment = finalAttrs.meta.description;
      categories = [ "Network" ];
      startupWMClass = "Komi-Store";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform app store for GitHub releases";
    homepage = "https://github.com/kurikomi-labs/komi-store";
    changelog = "https://github.com/kurikomi-labs/komi-store/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mio ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "komi-store";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # mitm cache
    ];
  };
})
