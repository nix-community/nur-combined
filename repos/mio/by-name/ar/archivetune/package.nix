{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_9,
  jdk21,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  cups,
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
  zlib,
}:

let
  jdk = jdk21;
  gradle = gradle_9.override { java = jdk; };

  # Compose Desktop native launcher + Skiko/JNA runtime libs.
  runtimeLibs = [
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

  # The :core submodule lives in a separate repo; fetch it at the pinned commit.
  coreSrc = fetchFromGitHub {
    owner = "rukamori";
    repo = "core";
    rev = "04672efc8606cdb3c77b56579c5123bc1c803e3a";
    hash = "sha256-bvrbaeuUA7ffUVFoQD4+xPnCJKpunNwjS8ihxHBtHVo=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "archivetune";
  version = "15.0.0";

  strictDeps = true;

  src = fetchFromGitHub {
    owner = "rukamori";
    repo = "ArchiveTune";
    rev = "9ed48d85b715f347b140b3f7c8729e3e79b0dac2";
    hash = "sha256-d91C0c40Icv3vkUsk6gFz03cLCTSdg8Hf9XeezYgOiM=";
  };

  patches = [ ];

  postPatch = ''
    # Wire the pinned :core submodule source into place.
    rm -rf core
    cp -r ${coreSrc} core
    chmod -R +w core

    # Add the :desktop module
    mkdir -p desktop/src/jvmMain/kotlin/moe/rukamori/archivetune/desktop
    cp ${./desktop-build.gradle.kts} desktop/build.gradle.kts
    cp ${./desktop-Main.kt} desktop/src/jvmMain/kotlin/moe/rukamori/archivetune/desktop/Main.kt

    # Wire the :desktop module into settings.gradle.kts
    sed -i '/include(":app")/d' settings.gradle.kts
    sed -i '/include(":lyrics/d' settings.gradle.kts
    sed -i '/include(":lastfm")/d' settings.gradle.kts
    sed -i '/include(":canvas")/d' settings.gradle.kts
    sed -i '/include(":shazamkit")/d' settings.gradle.kts
    sed -i '/include(":spotifycore")/d' settings.gradle.kts
    sed -i '/include(":morideobfuscator")/d' settings.gradle.kts
    echo 'include(":desktop")' >> settings.gradle.kts
    sed -i '/mavenCentral()/i \        maven("https://maven.pkg.jetbrains.space/public/p/compose/dev")' settings.gradle.kts

    # Add Compose Multiplatform to the root build.gradle.kts
    sed -i '/alias(libs.plugins.compose.compiler) apply false/a \    alias(libs.plugins.compose.multiplatform) apply false' build.gradle.kts

    # Update gradle/libs.versions.toml with required versions and plugins
    sed -i '/^compose = /a compose-multiplatform = "1.8.1"\nskiko = "0.9.4.1"' gradle/libs.versions.toml
    sed -i '/^compose-compiler = /a compose-multiplatform = { id = "org.jetbrains.compose", version.ref = "compose-multiplatform" }' gradle/libs.versions.toml

    # Disable configuration cache (flaky under Gradle MITM proxy).
    sed -i 's/org.gradle.configuration-cache=true/org.gradle.configuration-cache=false/' gradle.properties || true
    echo 'org.gradle.vfs.watch=false' >> gradle.properties

    # Silence the JVM OOM settings that conflict with sandbox memory limits.
    sed -i 's/-Xmx[0-9]*[MmGg]//g; s/-Dkotlin.daemon.jvm.options=[^ ]*//' gradle.properties || true
    echo 'org.gradle.jvmargs=-Dfile.encoding=UTF-8' >> gradle.properties
  '';

  env.JAVA_HOME = jdk;

  gradleFlags = [
    "-Dorg.gradle.java.home=${jdk}"
    "-Dfile.encoding=utf-8"
    "-Dorg.gradle.native=false"
  ];

  gradleBuildTask = ":desktop:createReleaseDistributable";
  gradleUpdateTask = finalAttrs.gradleBuildTask;

  gradleUpdateScript = ''
    runHook preBuild

    # Pull host-native Skiko + arm64/macOS variants so the deps cache is portable.
    gradle :desktop:composeApp 2>/dev/null || true
    gradle ${finalAttrs.gradleBuildTask}

    runHook postGradleUpdate
  '';

  nativeBuildInputs = [
    copyDesktopItems
    gradle
    jdk
    makeWrapper
    autoPatchelfHook
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

  preConfigure = ''
    export ANDROID_USER_HOME="$TMPDIR/android"
    export GRADLE_USER_HOME="$TMPDIR/gradle"
    mkdir -p "$ANDROID_USER_HOME" "$GRADLE_USER_HOME"
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -a desktop/build/compose/binaries/main-release/app/ArchiveTune $out/lib/archivetune

    # Replace the bundled JRE with the nixpkgs one.
    rm -rf $out/lib/archivetune/lib/runtime
    ln -s ${jdk.home} $out/lib/archivetune/lib/runtime

    install -Dm644 desktop/src/jvmMain/resources/icon.png \
      $out/share/icons/hicolor/512x512/apps/archivetune.png 2>/dev/null || true

    runHook postInstall
  '';

  preFixup = ''
    makeWrapper $out/lib/archivetune/bin/ArchiveTune $out/bin/archivetune \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "archivetune";
      exec = "archivetune";
      icon = "archivetune";
      desktopName = "ArchiveTune";
      genericName = "Music Player";
      comment = "The Cutest Music Player with YouTube Music support";
      categories = [
        "AudioVideo"
        "Audio"
        "Player"
      ];
      startupWMClass = "ArchiveTune";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cute music player with local file and YouTube Music support (Linux desktop via Compose Multiplatform)";
    homepage = "https://github.com/rukamori/ArchiveTune";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mio ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "archivetune";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # gradle mitm cache
    ];
  };
})
