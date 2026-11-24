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
  imagemagick,
  libicns,
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
  mpv,
  mpv-unwrapped,
  mpvScripts ? null,
  yt-dlp,
  nix-update,
  nix,
  curl,
  zlib,
}:

let
  jdk = jdk21;
  gradle = gradle_9.override { java = jdk; };

  mpvPkg =
    if (stdenv.hostPlatform.isLinux && mpvScripts != null) then
      (mpv.override { scripts = [ mpvScripts.mpris ]; })
    else if stdenv.hostPlatform.isDarwin then
      # nixpkgs' mpv 0.42 is built with libcurl on darwin and segfaults right
      # after startup, before the IPC socket is created. Dropping libcurl makes
      # it use ffmpeg's HTTP stack for streaming instead.
      mpv.override { mpv-unwrapped = mpv-unwrapped.override { curlSupport = false; }; }
    else
      mpv;

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

  # The :lyrics submodule supplies the JVM-only lyrics providers (lrc.red, kugou,
  # paxsenix, TTML parsers...); it is pure Kotlin/JVM, so the port builds it for real.
  lyricsSrc = fetchFromGitHub {
    owner = "rukamori";
    repo = "lyrics";
    rev = "182e0d3a86bb94c9f5e5b7d90b8f91f7cee1c8ec";
    hash = "sha256-SaDa80YYHG6EO91wDEa0j7cn4eP1DxGDfvry8YjqJEc=";
  };

  # The :core submodule lives in a separate repo; fetch it at the pinned commit.
  coreSrc = fetchFromGitHub {
    owner = "rukamori";
    repo = "core";
    rev = "c331f66f3cfb7b1dfcf77599eb284a9a4974c55a";
    hash = "sha256-j6S1dxEMSY1HRv/5vQUGrL6tDsWoeYH2s54ZXRbvrGE=";
  };
  unwrapped = stdenv.mkDerivation (finalAttrs: {
    pname = "archivetune-unwrapped";
    version = "16.1.0";

    strictDeps = true;

    src = fetchFromGitHub {
      owner = "rukamori";
      repo = "ArchiveTune";
      tag = "v${finalAttrs.version}";
      hash = "sha256-QAt3PkBpDDREKIVmXkAOnwCo9FdiFkIII1sZ+Rrf33A=";
    };

    patches = [ ];

    postPatch = ''
      # Wire the pinned :core and :lyrics submodule sources into place.
      rm -rf core lyrics
      cp -r ${coreSrc} core
      cp -r ${lyricsSrc} lyrics
      chmod -R +w core lyrics
      patch -p1 < ${./core-playlist.patch}

      # Drop the Android-only entrypoints. android-stubs provides the global mocks
      # that used to live in MainActivity.kt, and DesktopMain.kt is our new entrypoint.
      rm -f app/src/main/kotlin/moe/rukamori/archivetune/MainActivity.kt
      rm -f app/src/main/kotlin/moe/rukamori/archivetune/DebugActivity.kt
      rm -f app/src/main/kotlin/moe/rukamori/archivetune/RestoreBackupFileActivity.kt
      rm -rf app/src/main/kotlin/moe/rukamori/archivetune/widget
      rm -rf app/src/main/kotlin/moe/rukamori/archivetune/aod
      # Media3 player decorator used only by the Android MusicService, which the port replaces.
      rm -f app/src/main/kotlin/moe/rukamori/archivetune/playback/MediaSessionNavigationPlayer.kt

      # Files the port replaces wholesale. These are kept as real files rather than
      # as full-file patches: upstream rewrites them constantly (adding flavours,
      # SDK levels, dependencies...), and a full-file patch breaks on every touch
      # while contributing nothing, since the replacement is intentional.
      install -m644 ${./files/app-build.gradle.kts} app/build.gradle.kts
      install -m644 ${./files/settings.gradle.kts} settings.gradle.kts
      install -m644 ${./files/modules-build.gradle.kts} modules/build.gradle.kts
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
      install -m644 ${./files/ComposeToImage.kt} app/src/main/kotlin/moe/rukamori/archivetune/utils/ComposeToImage.kt
      install -m644 ${./files/ExoDownloadService.kt} app/src/main/kotlin/moe/rukamori/archivetune/playback/ExoDownloadService.kt
      install -m644 ${./files/UpdateNotificationManager.kt} app/src/main/kotlin/moe/rukamori/archivetune/utils/UpdateNotificationManager.kt
      install -m644 ${./files/Updater.kt} app/src/main/kotlin/moe/rukamori/archivetune/utils/Updater.kt
      install -m644 ${./files/DesktopLoginScreen.kt} app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/LoginScreen.kt

      install -m644 ${./files/DesktopMain.kt} app/src/main/kotlin/moe/rukamori/archivetune/DesktopMain.kt

      # Fix shapes parameter in TextButton/SegmentedButton (avoid mangling MaterialTheme.shapes.xxx)
      find app/src/main/kotlin -type f -name "*.kt" -exec sed -i "s/@DrawableRes//g" {} +
      find app/src/main/kotlin -type f -name "*.kt" -exec sed -i "s/shapes = ButtonDefaults.shapes()/shape = ButtonDefaults.textShape/g" {} +
      find app/src/main/kotlin -type f -name "*.kt" -exec sed -i "s/shapes = SegmentedButtonDefaults/shape = SegmentedButtonDefaults/g" {} +
      # Remaining small source patches
      patch -p1 < ${./root-build.patch}
      patch -p1 < ${./app-kotlin.patch}
      patch -p1 < ${./app-source.patch}
      patch -p1 < ${./history-refresh.patch}
      # Drop the Android-only subsystems (see narrow.py), then shim the rest.
      python3 ${./narrow.py}
      # Android-only USB bit-perfect stack (removed by narrow.py) keeps its type surface.
      mkdir -p app/src/main/kotlin/moe/rukamori/archivetune/playback/bitperfect
      install -m644 ${./files/BitPerfectShim.kt} \
        app/src/main/kotlin/moe/rukamori/archivetune/playback/bitperfect/BitPerfectOutput.kt
      python3 ${./fix_theme.py}
      patch -p1 < ${./sed-replacements.patch}

      # Compose Desktop's DialogProperties has no Android window-insets flag.
      find app/src/main/kotlin -type f -name "*.kt" -exec sed -i "/decorFitsSystemWindows = false,/d" {} +

      cp ${./files/MusicDatabase.kt} app/src/main/kotlin/moe/rukamori/archivetune/db/MusicDatabase.kt
      cp ${./files/DatabaseDao.kt} app/src/main/kotlin/moe/rukamori/archivetune/db/DatabaseDao.kt
      # JVM implementations of the two Android-only Room helpers the KSP code generator emits
      # (see the file header). Placed in Room's own package so the generated DAO links.
      mkdir -p app/src/main/kotlin/androidx/room/util
      cp ${./files/RoomJvmSupport.kt} app/src/main/kotlin/androidx/room/util/RoomJvmSupport.kt

      # Copy android stubs
      cp -r ${./android-stubs} android-stubs
      chmod -R +w .

      # R.string and stringResource live outside the Android resource compiler in
      # this port, so derive them from upstream's values/*.xml.
      python3 ${./files/gen_string_resources.py}

      # Populate android-stubs resources with upstream drawables
      mkdir -p android-stubs/src/main/resources/drawable
      cp -r app/src/main/res/drawable/* android-stubs/src/main/resources/drawable/

      # Sanitize all XML vector drawables in both app and android-stubs for Compose Desktop
      python3 ${./files/sanitize_drawables.py}

      # Bypass NetworkGatekeeper unofficial build block
      substituteInPlace core/src/main/kotlin/moe/rukamori/archivetune/innertube/NetworkGatekeeper.kt \
        --replace-fail "AtomicBoolean(true)" "AtomicBoolean(false)"

      # Keep the latest local-history write so the history tab can reload after it subscribes.
      substituteInPlace core/src/main/kotlin/moe/rukamori/archivetune/innertube/YouTube.kt \
        --replace-fail "MutableSharedFlow<Unit>(extraBufferCapacity = 1)" "MutableSharedFlow<Unit>(replay = 1, extraBufferCapacity = 1)"

      # Replace Looper.getMainLooper() main thread check in DataStore.kt with native AWT EventQueue.isDispatchThread()
      substituteInPlace app/src/main/kotlin/moe/rukamori/archivetune/utils/DataStore.kt \
        --replace-fail "import android.os.Looper" "import java.awt.EventQueue" \
        --replace-fail "Looper.getMainLooper().thread == Thread.currentThread()" "EventQueue.isDispatchThread()"

      # Import all carousel extensions in NewsScreen.kt (such as currentItem)
      substituteInPlace app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/NewsScreen.kt \
        --replace-fail "import androidx.compose.material3.carousel.HorizontalCenteredHeroCarousel" \
                       "import androidx.compose.material3.carousel.*"

      # Prevent ExploreScreen from returning early when backStackEntry is null
      substituteInPlace app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/ExploreScreen.kt \
        --replace-fail "val scrollToTop by backStackEntry" "val scrollToTop = backStackEntry" \
        --replace-fail "?.collectAsState() ?: return" "?.collectAsState()?.value ?: false"

      # Pass preloadItem to YouTubeQueue.playlist in HomeScreenComponents.kt
      substituteInPlace app/src/main/kotlin/moe/rukamori/archivetune/ui/screens/HomeScreenComponents.kt \
        --replace-fail "playerConnection.playQueue(YouTubeQueue.playlist(songEndpoint))" \
                       "playerConnection.playQueue(YouTubeQueue.playlist(songEndpoint, song.toMediaMetadata()))"

      # Simplify BotGuardTokenGenerator patches
      python3 ${./files/patch_botguard.py}

      # Generate macOS icns icon
      mkdir -p app/build/iconset
      for s in 16 32 48 128 256 512 1024; do
        magick app/src/main/res/mipmap-xxxhdpi/ic_launcher.png -resize ''${s}x''${s} app/build/iconset/icon_''${s}.png
      done
      png2icns app/ArchiveTune.icns app/build/iconset/icon_*.png
      rm -rf app/build/iconset

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

      # deps.json is shared by every Nix host, but compose.desktop.currentOs only pulls
      # the desktop binaries of the OS Gradle thinks it runs on. Resolve the whole
      # dependency graph once per supported target (the nixpkgs gradle setup hook
      # supplies nixDownloadDeps under IN_GRADLE_UPDATE_DEPS) so a lock generated on
      # darwin also builds on linux and vice versa.
      gradle :app:nixDownloadDeps -Dos.name=Linux -Dos.arch=amd64
      gradle :app:nixDownloadDeps -Dos.name=Linux -Dos.arch=aarch64
      gradle :app:nixDownloadDeps -Dos.name='Mac OS X' -Dos.arch=amd64
      gradle :app:nixDownloadDeps -Dos.name='Mac OS X' -Dos.arch=aarch64

      # Pull host-native Skiko + arm64/macOS variants so the deps cache is portable.
      gradle :app:composeApp 2>/dev/null || true
      gradle ${finalAttrs.gradleBuildTask}

      runHook postGradleUpdate
    '';

    nativeBuildInputs = [
      imagemagick
      libicns
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
    sandboxProfile = lib.optionalString stdenv.hostPlatform.isDarwin ''
      (allow file-read* (literal "/usr/bin/codesign"))
      (allow process-exec (literal "/usr/bin/codesign"))
      (allow process-fork)
    '';

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

        cp -f app/ArchiveTune.icns $out/Applications/ArchiveTune.app/Contents/Resources/ArchiveTune.icns
        if [ -x /usr/bin/codesign ]; then
          /usr/bin/codesign -f -s - $out/Applications/ArchiveTune.app || true
        fi
        
        mkdir -p $out/bin
        makeWrapper $out/Applications/ArchiveTune.app/Contents/MacOS/ArchiveTune $out/bin/archivetune
      else
        # linux
        cp -a app/build/compose/binaries/main-release/app/ArchiveTune $out/lib/archivetune

        # Replace the bundled JRE with the nixpkgs one.
        rm -rf $out/lib/archivetune/lib/runtime
        ln -s ${jdk.home} $out/lib/archivetune/lib/runtime

        for s in 16 32 48 64 128 256 512; do
          mkdir -p "$out/share/icons/hicolor/''${s}x''${s}/apps"
          magick app/src/main/res/mipmap-xxxhdpi/ic_launcher.png -resize ''${s}x''${s} \
            "$out/share/icons/hicolor/''${s}x''${s}/apps/archivetune.png"
        done
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
      runtimeInputs = [
        nix-update
        nix
        curl
        python3
      ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="archivetune.unwrapped"
        exec ${python3}/bin/python3 ${./update.py} "$@"
      '';
    };

    meta = {
      description = "Cute music player with local file and YouTube Music support (Desktop via Compose Multiplatform)";
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
  });
in
stdenv.mkDerivation {
  pname = "archivetune";
  inherit (unwrapped) version meta;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;

  sandboxProfile = lib.optionalString stdenv.hostPlatform.isDarwin ''
    (allow file-read* (literal "/usr/bin/codesign"))
    (allow process-exec (literal "/usr/bin/codesign"))
    (allow process-fork)
  '';

  installPhase = ''
    mkdir -p $out
    cp -a ${unwrapped}/* $out/
    chmod -R u+w $out
    rm -f $out/bin/archivetune

    mkdir -p $out/bin
    if [ -d $out/Applications/ArchiveTune.app ]; then
      if [ -f $out/Applications/ArchiveTune.app/Contents/app/ArchiveTune.cfg ]; then
        echo "java-options=-Darchivetune.mpv.path=${mpvPkg}/bin/mpv" >> $out/Applications/ArchiveTune.app/Contents/app/ArchiveTune.cfg
        echo "java-options=-Xdock:icon=$out/Applications/ArchiveTune.app/Contents/Resources/ArchiveTune.icns" >> $out/Applications/ArchiveTune.app/Contents/app/ArchiveTune.cfg
      fi

      makeWrapper $out/Applications/ArchiveTune.app/Contents/MacOS/ArchiveTune $out/bin/archivetune \
        --prefix PATH : "${
          lib.makeBinPath [
            mpvPkg
            yt-dlp
          ]
        }" \
        --set ARCHIVETUNE_MPV_PATH "${mpvPkg}/bin/mpv"
    else
      if [ -f $out/lib/archivetune/lib/app/ArchiveTune.cfg ]; then
        echo "java-options=-Darchivetune.mpv.path=${mpvPkg}/bin/mpv" >> $out/lib/archivetune/lib/app/ArchiveTune.cfg
      fi

      makeWrapper $out/lib/archivetune/bin/ArchiveTune $out/bin/archivetune \
        --prefix PATH : "${
          lib.makeBinPath [
            mpvPkg
            yt-dlp
          ]
        }" \
        --set ARCHIVETUNE_MPV_PATH "${mpvPkg}/bin/mpv" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
    fi
  '';

  postFixup = ''
    if [ -d $out/Applications/ArchiveTune.app ] && [ -x /usr/bin/codesign ]; then
      /usr/bin/codesign -f -s - $out/Applications/ArchiveTune.app || true
    fi
  '';

  passthru = (unwrapped.passthru or { }) // {
    inherit unwrapped;
  };
}
