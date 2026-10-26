{
  lib,
  source,
  # Upstream's pubspec floor is Flutter >=3.44.9, and nixpkgs' 3.44 series stops
  # at 3.44.4, so 3.47 is the lowest series here that resolves the lock at all.
  flutter347,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  gst_all_1,
  keybinder3,
  libayatana-appindicator,
  callPackage,
  path,
  sqlite,
  writeScript,
}: let
  pname = "kelivo";
  inherit (source) src version;

  # `audioplayers` dlopens decoders from the plugin search path, not from DT_NEEDED.
  gstPlugins = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ];

  # nixpkgs makes libsqlcipher an unconditional runtime dependency of pub `sqlite3` >=3.5.0 but only carries its hash for 3.5.0 on x86_64-linux, so every other version and system throws at evaluation time.
  # kelivo drives drift against plain sqlite3 and never looks sqlcipher up, so drop it rather than pin hashes that the lockfile update workflow invalidates on each bump.
  sqlite3SourceBuilder = args:
    (callPackage (path + "/pkgs/development/compilers/dart/package-source-builders/sqlite3") {} args).overrideAttrs {
      setupHook = writeScript "sqlite3-setup-hook" ''
        sqliteFixupHook() {
          runtimeDependencies+=('${lib.getLib sqlite}')
        }

        preFixupHooks+=(sqliteFixupHook)
      '';
    };
in
  flutter347.buildFlutterApplication {
    inherit pname src version;

    pubspecLock = lib.importJSON ./pubspec.lock.json;

    customSourceBuilders.sqlite3 = sqlite3SourceBuilder;

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
