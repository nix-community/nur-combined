{
  lib,
  source,
  flutter344,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  gst_all_1,
  keybinder3,
  libayatana-appindicator,
}: let
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  # `audioplayers` dlopens decoders from the plugin search path, not from DT_NEEDED.
  gstPlugins = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ];

  # The same narrowing `buildFlutterApplication` applies internally, named here so
  # resolving the lock reuses the build's SDK closure instead of realizing a second
  # one that also carries the unused Android and Web engine artifacts.
  flutterForPub = flutter344.override {
    supportedTargetFlutterPlatforms = [
      "universal"
      "linux"
    ];
  };
in
  flutter344.buildFlutterApplication {
    inherit pname src version;

    # Upstream gitignores pubspec.lock; update-lockfiles resolves and commits this.
    pubspecLock = lib.importJSON ./pubspec.lock.json;

    # `lib/secrets/fallback.dart` is gitignored but imported unconditionally by
    # lib/core/providers/model_provider.dart. Upstream CI injects a SiliconFlow
    # key here; an empty one only disables the bundled free models.
    postPatch = ''
      mkdir -p lib/secrets
      echo 'const String siliconflowFallbackKey = "";' > lib/secrets/fallback.dart
    '';

    # Required, not optional: the `sqlite3` package source builder hands sqlite over
    # through `runtimeDependencies`, and `sherpa_onnx_linux` ships prebuilt shared
    # objects that need their interpreter and rpath rewritten.
    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
    ];

    buildInputs = [
      keybinder3 # hotkey_manager
      libayatana-appindicator # tray_manager
      gst_all_1.gstreamer # audioplayers
      gst_all_1.gst-plugins-base
    ];

    extraWrapProgramArgs = ''
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPlugins}"
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "kelivo";
        exec = "kelivo %U";
        icon = "kelivo";
        desktopName = "Kelivo";
        startupWMClass = "com.psyche.kelivo";
        comment = "A Flutter LLM chat client";
        categories = [
          "Network"
          "Chat"
        ];
      })
    ];

    # `assets/app_icon.png` is 1024x1024; install it at its real size.
    postInstall = ''
      install -Dm644 assets/app_icon.png \
        $out/share/icons/hicolor/1024x1024/apps/kelivo.png
    '';

    # update-lockfiles resolves pubspec.lock with this; the version lives here only.
    passthru.pubLockFlutter = flutterForPub;

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      test -x $out/bin/kelivo
      test -f $out/share/applications/kelivo.desktop
      test -f $out/share/icons/hicolor/1024x1024/apps/kelivo.png

      # Verify the GStreamer plugin path reached the wrapper.
      grep -F 'GST_PLUGIN_SYSTEM_PATH_1_0' $out/bin/kelivo

      runHook postInstallCheck
    '';

    meta = {
      description = "A Flutter LLM chat client";
      homepage = "https://github.com/Chevey339/kelivo";
      changelog = "https://github.com/Chevey339/kelivo/releases/tag/v${version}";
      license = lib.licenses.agpl3Only;
      mainProgram = "kelivo";
      # `sherpa_onnx_linux` distributes a prebuilt libonnxruntime.so through pub.
      sourceProvenance = with lib.sourceTypes; [
        fromSource
        binaryNativeCode
      ];
      maintainers = [
        {
          name = "mzwing";
        }
      ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  }
