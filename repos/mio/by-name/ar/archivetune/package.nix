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

    # Rename android main to old_android_main to preserve it as reference
    mv app/src/main app/src/old_android_main
    mkdir -p app/src/main/kotlin/moe/rukamori/archivetune/ui/screens

    # Copy our desktop UI components
    cp -r  ${./src}/* ./

    # Apply build script patches
    patch -p1 < ${./root-build.patch}
    patch -p1 < ${./settings.patch}
    patch -p1 < ${./app-build.patch}
    
    # Copy android stubs
    cp -r  ${./android-stubs} android-stubs
    chmod -R +w .
    ls -la android-stubs

    # We also have migration-patches if the user wants to apply them manually
    cp -r ${./migration-patches} patches/
    chmod -R +w .
  '';

  env.JAVA_HOME = jdk;

  gradleFlags = [
    "-Dorg.gradle.java.home=${jdk}"
    "-Dfile.encoding=utf-8"
    "-Dorg.gradle.native=false"
    "-Djava.net.preferIPv4Stack=true"
    "--no-daemon"
  ];

  gradleBuildTask = ":app:createReleaseDistributable";
  gradleUpdateTask = finalAttrs.gradleBuildTask;

  gradleUpdateScript = ''
    runHook preBuild

    # Pull host-native Skiko + arm64/macOS variants so the deps cache is portable.
    gradle :app:composeApp 2>/dev/null || true
    gradle ${finalAttrs.gradleBuildTask}

    runHook postGradleUpdate
  '';

  nativeBuildInputs = [
    gradle
    jdk
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    copyDesktopItems
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

  preBuild = ''
    export HOME=$(mktemp -d)
    export ANDROID_USER_HOME="$HOME/.android"
    mkdir -p "$ANDROID_USER_HOME"
    export JAVA_TOOL_OPTIONS="-Djava.net.preferIPv4Stack=true"
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib

    if [ -d app/build/compose/binaries/main-release/app/ArchiveTune.app ]; then
      # macOS
      mkdir -p $out/Applications
      cp -a app/build/compose/binaries/main-release/app/ArchiveTune.app $out/Applications/
      
      # Replace the bundled JRE with the nixpkgs one.
      rm -rf $out/Applications/ArchiveTune.app/Contents/runtime
      jdk_mac=$(ls -d ${jdk.home}/Library/Java/JavaVirtualMachines/*.jdk)
      ln -s "$jdk_mac" $out/Applications/ArchiveTune.app/Contents/runtime
      
      mkdir -p $out/bin
      makeWrapper $out/Applications/ArchiveTune.app/Contents/MacOS/ArchiveTune $out/bin/archivetune
    else
      # linux
      cp -a app/build/compose/binaries/main-release/app/ArchiveTune $out/lib/archivetune

      # Replace the bundled JRE with the nixpkgs one.
      rm -rf $out/lib/archivetune/lib/runtime
      ln -s ${jdk.home} $out/lib/archivetune/lib/runtime

      install -Dm644 app/src/main/res/mipmap-xxxhdpi/ic_launcher.png \
        $out/share/icons/hicolor/512x512/apps/archivetune.png 2>/dev/null || true
    fi

    runHook postInstall
  '';

  preFixup = ''
    if [ -d $out/lib/archivetune ]; then
      makeWrapper $out/lib/archivetune/bin/ArchiveTune $out/bin/archivetune \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
    fi
  '';

  desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
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
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "archivetune";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # gradle mitm cache
    ];
  };
})
