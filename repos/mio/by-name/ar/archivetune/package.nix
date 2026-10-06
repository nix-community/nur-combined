{
  lib,
  writeShellApplication,
  stdenv,
  python3,
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
    rev = "f9e316fb7ec10d14487004db07e3b37d7afdfef3";
    hash = "sha256-r+3g/fPG963NtYqWQ5VGmqglGMnkeegeZCV6GajCICE=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "archivetune";
  version = "15.1.0";

  strictDeps = true;

  src = fetchFromGitHub {
    owner = "rukamori";
    repo = "ArchiveTune";
    rev = "2f48b8159ecca45ae39394e2eb0d0b946e6b06f9";
    hash = "sha256-xzhpLlX+X+Mx+VAgKbkTIB2ntAFfMhqrQCE1diZTFng=";
  };

  patches = [ ];

  postPatch = ''

    # Wire the pinned :core submodule source into place.
    rm -rf core
    cp -r ${coreSrc} core
    chmod -R +w core

    # Drop the Android-only entrypoints. android-stubs provides the global mocks
    # that used to live in MainActivity.kt, and DesktopMain.kt is our new entrypoint.
    rm -f app/src/main/kotlin/moe/rukamori/archivetune/MainActivity.kt
    rm -f app/src/main/kotlin/moe/rukamori/archivetune/DebugActivity.kt
    rm -f app/src/main/kotlin/moe/rukamori/archivetune/RestoreBackupFileActivity.kt
    rm -rf app/src/main/kotlin/moe/rukamori/archivetune/widget
    rm -rf app/src/main/kotlin/moe/rukamori/archivetune/aod

    # Files the port replaces wholesale. These are kept as real files rather than
    # as full-file patches: upstream rewrites them constantly (adding flavours,
    # SDK levels, dependencies...), and a full-file patch breaks on every touch
    # while contributing nothing, since the replacement is intentional.
    install -m644 ${./files/app-build.gradle.kts} app/build.gradle.kts
    install -m644 ${./files/settings.gradle.kts} settings.gradle.kts
    install -m644 ${./files/AodShapeUtils.kt} app/src/main/kotlin/moe/rukamori/archivetune/ui/utils/AodShapeUtils.kt
    install -m644 ${./files/ShowMediaInfo.kt} app/src/main/kotlin/moe/rukamori/archivetune/ui/utils/ShowMediaInfo.kt
    install -m644 ${./files/AppUpdateInstaller.kt} app/src/main/kotlin/moe/rukamori/archivetune/utils/AppUpdateInstaller.kt
    # Android-only playback service layer. MusicService is a MediaSessionService and
    # the widgets are Glance-based; neither exists on the JVM desktop, so the port
    # keeps only the type surface the rest of the app resolves against.
    install -m644 ${./files/MusicService.kt} app/src/main/kotlin/moe/rukamori/archivetune/playback/MusicService.kt
    install -m644 ${./files/MediaLibrarySessionCallback.kt} app/src/main/kotlin/moe/rukamori/archivetune/playback/MediaLibrarySessionCallback.kt
    install -m644 ${./files/MusicServiceWidgetUpdater.kt} app/src/main/kotlin/moe/rukamori/archivetune/playback/MusicServiceWidgetUpdater.kt
    install -m644 ${./files/DownloadUtil.kt} app/src/main/kotlin/moe/rukamori/archivetune/playback/DownloadUtil.kt
    # Stand-in for the :morideobfuscator Android library (own repo, not fetched):
    # real model/data types plus an inert resolver.
    mkdir -p app/src/main/kotlin/moe/rukamori/archivetune/morideobfuscator/youtubei
    install -m644 ${./files/YoutubeiModels.kt} app/src/main/kotlin/moe/rukamori/archivetune/morideobfuscator/youtubei/YoutubeiModels.kt
    install -m644 ${./files/YoutubeiResolver.kt} app/src/main/kotlin/moe/rukamori/archivetune/morideobfuscator/youtubei/YoutubeiResolver.kt
    # Inert stand-ins for the dropped AOD player surface and the Discord presence
    # manager that the (kept) debug settings screen still renders.
    install -m644 ${./files/AodPlayerScreen.kt} app/src/main/kotlin/moe/rukamori/archivetune/ui/player/AodPlayerScreen.kt
    install -m644 ${./files/DiscordPresenceManager.kt} app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/settings/DiscordPresenceManager.kt

    # Copy our desktop UI components
    patch -p1 < ${./desktop-ui.patch}

    # Fix shapes parameter in TextButton/SegmentedButton (avoid mangling MaterialTheme.shapes.xxx)
    find app/src/main/kotlin -type f -name "*.kt" -exec sed -i "s/@DrawableRes//g" {} +
    find app/src/main/kotlin -type f -name "*.kt" -exec sed -i "s/shapes = ButtonDefaults.shapes()/shape = ButtonDefaults.textShape/g" {} +
    find app/src/main/kotlin -type f -name "*.kt" -exec sed -i "s/shapes = SegmentedButtonDefaults/shape = SegmentedButtonDefaults/g" {} +
    find app/src/main/kotlin -type f -name "*.kt" -exec sed -i "s/shapes = IconButtonDefaults/shape = IconButtonDefaults/g" {} +
    find app/src/main/kotlin -type f -name "*.kt" -exec sed -i "s/shapes = expressiveShapes/shapes = expressiveShapes/g" {} +
    # Remaining small source patches
    patch -p1 < ${./root-build.patch}
    patch -p1 < ${./app-kotlin.patch}
    patch -p1 < ${./app-source.patch}
    # Drop the Android-only subsystems (see narrow.py), then shim the rest.
    python3 ${./narrow.py}
    python3 ${./fix_theme.py}
    patch -p1 < ${./challenge.patch}
    sed -i "s/chain.withRequest(refreshedRequest).proceed()/chain.proceed(refreshedRequest)/g" app/src/main/kotlin/moe/rukamori/archivetune/utils/PlaylistCoverInterceptor.kt
    sed -i "s/image = result.image,/result.image,/" app/src/main/kotlin/moe/rukamori/archivetune/utils/PlaylistCoverInterceptor.kt
    sed -i "s/request = request,/request,/" app/src/main/kotlin/moe/rukamori/archivetune/utils/PlaylistCoverInterceptor.kt
    sed -i "s/throwable = exception,/exception/" app/src/main/kotlin/moe/rukamori/archivetune/utils/PlaylistCoverInterceptor.kt

    # Java getter read as a property: media3's DownloadService exposes getDownloadManager(),
    # which Kotlin does not synthesise into `downloadManager` for a Kotlin-declared base class.
    sed -i "s/^\( *\)downloadManager\./\1getDownloadManager()./" app/src/main/kotlin/moe/rukamori/archivetune/playback/ExoDownloadService.kt

    # Java getters on media3's Cache are reached as properties by these two files, which do not
    # import the port's extension forms. fix_theme.py's markers are case-sensitive and cannot
    # match them without also hitting unrelated files, so add the imports here.
    sed -i "0,/^import /s//import androidx.media3.datasource.cache.cacheSpace\n&/" \
      app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/settings/StorageSettings.kt
    sed -i "0,/^import /s//import androidx.media3.datasource.cache.keys\n&/" \
      app/src/main/kotlin/moe/rukamori/archivetune/viewmodels/CachePlaylistViewModel.kt

    # material3 1.9's SliderDefaults.Track takes trackCornerSize; the port's compose 1.7 does not,
    # so drop that named argument from upstream's slider call sites.
    sed -i "s/^\( *\)trackCornerSize = 12.dp,$//" \
      app/src/main/kotlin/moe/rukamori/archivetune/ui/component/Preference.kt

    # Build.VERSION_CODES.VANILLA_ICE_CREAM (API 35) is absent from the robolectric android-all
    # jar (API 34) the port compiles against.
    sed -i "s/Build\.VERSION_CODES\.VANILLA_ICE_CREAM/35/g" \
      app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/settings/AppearanceSettings.kt

    # Long + String has no plus overload upstream relies on; build the key explicitly.
    # (No shell/nix expansions here on purpose: the phase is eval'd and this file is a nix string.)
    sed -i 's/key(entry\.timestamp + entry\.endpoint)/key(entry.timestamp.toString() + entry.endpoint)/' \
      app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/settings/LyricsSettings.kt

    # The port's paint stub exposes `typeface` as a String setter; upstream assigns a Typeface, so
    # use the setter method form instead.
    sed -i 's/typeface = \(Typeface\..*\)$/setTypeface(\1)/' \
      app/src/main/kotlin/moe/rukamori/archivetune/utils/ComposeToImage.kt

    # The transition scope's targetState/initialState are nullable in the navigation version the
    # port resolves; upstream dereferences them directly.
    sed -i 's/targetState\.destination\.route/targetState?.destination?.route/g' \
      app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/NavigationBuilder.kt
    sed -i 's/initialState\.destination\.route/initialState?.destination?.route/g' \
      app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/NavigationBuilder.kt

    # FilterChip(shapes = ...) is material3 1.9 API; compose 1.7 has no such parameter.
    sed -i "s/^\( *\)shapes = FilterChipDefaults.shapes(),$//" \
      app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/HomeScreenComponents.kt

    # DialogProperties(decorFitsSystemWindows = ...) is a newer compose field than 1.7 provides.
    sed -i "s/^\( *\)decorFitsSystemWindows = false,$//" \
      app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/settings/AboutScreen.kt \
      app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/ViewNewsScreen.kt

    # DesktopMain.kt (from desktop-ui.patch) calls SettingsScreen with two arguments, but the
    # screen gained a third parameter upstream.
    sed -i "s/SettingsScreen(TODO(), TODO())/SettingsScreen(TODO(), TODO(), TODO())/" \
      app/src/main/kotlin/moe/rukamori/archivetune/DesktopMain.kt
    # LibraryScreen's scrollBehavior parameter has no default.
    sed -i "s/LibraryScreen(TODO())/LibraryScreen(TODO(), TODO())/" \
      app/src/main/kotlin/moe/rukamori/archivetune/DesktopMain.kt

    # Copy android stubs
    cp -r  ${./android-stubs} android-stubs
    chmod -R +w .
    ls -la android-stubs
    # Simplify BotGuardTokenGenerator patches
    python3 << 'PYTHON_EOF'
import sys
content = open('app/src/main/kotlin/moe/rukamori/archivetune/utils/potoken/BotGuardTokenGenerator.kt').read()

html_block = """                val html =
                    withContext(Dispatchers.IO) {
                        webView.context.assets
                            .open("po_token.html")
                            .bufferedReader()
                            .use { it.readText() }
                    }"""
content = content.replace(html_block, '                val html = ""\n')

js_block = """                            webView.context.assets
                                .open("botguard.js")
                                .bufferedReader()
                                .use { it.readText() }"""
content = content.replace(js_block, '                            ""\n')

content = content.replace('wv.post(engine::close)', 'engine.close()')
open('app/src/main/kotlin/moe/rukamori/archivetune/utils/potoken/BotGuardTokenGenerator.kt', 'w').write(content)
PYTHON_EOF
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
    python3
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

  passthru.updateScript = writeShellApplication {
    name = "update-archivetune";
    text = ''
      export UPDATE_NIX_ATTR_PATH="archivetune"
      exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
    '';
  };

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
