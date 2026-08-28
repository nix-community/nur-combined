{
  lib,
  stdenv,
  flutter,
  callPackage,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  cocoapods,
  writableTmpDirAsHomeHook,
  wrapGAppsHook3,
  gtk3,
  glib,
  pcre2,
  pkg-config,
  clang,
  cmake,
  ninja,
  cacert,
}:

let
  buildFlutterApp = callPackage ./build-support/build-flutter-application.nix { };
in
lib.overrideDerivation
  (buildFlutterApp (
    {
      pname = "openscore";
      version = "0.1.0";
      src = ./.;

      targetFlutterPlatform = if stdenv.hostPlatform.isDarwin then "macos" else "linux";

      pubspecLock = lib.importJSON ./pubspec.lock.json;

      nativeBuildInputs = [
        pkg-config
        cmake
        ninja
        clang
        cacert
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        cocoapods
        writableTmpDirAsHomeHook
        makeWrapper
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        copyDesktopItems
        wrapGAppsHook3
      ];

      buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
        gtk3
        glib
        pcre2
      ];

      preBuild = lib.optionalString stdenv.hostPlatform.isDarwin ''
        mkdir -p .bin
        echo '#!/bin/sh' > .bin/sw_vers
        echo 'echo "ProductName: macOS"' >> .bin/sw_vers
        echo 'echo "ProductVersion: 13.0"' >> .bin/sw_vers
        echo 'echo "BuildVersion: 22A380"' >> .bin/sw_vers
        chmod +x .bin/sw_vers
        export PATH="$(pwd)/.bin:$PATH"
        chmod -R u+w macos || true
      '';

      dontUseCmakeConfigure = true;
      dontFixup = stdenv.hostPlatform.isDarwin;

      postPatch = ''
        rm -f linux/flutter/generated_plugin_registrant.cc \
          linux/flutter/generated_plugin_registrant.h \
          linux/flutter/generated_plugins.cmake
      '';

      desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
        (makeDesktopItem {
          name = "openscore";
          exec = "openscore";
          icon = "openscore";
          desktopName = "OpenScore";
          comment = "Download sheet music from MuseScore";
          categories = [
            "AudioVideo"
            "Audio"
            "Utility"
          ];
          startupWMClass = "openscore";
        })
      ];

      meta = {
        description = "Open-source MuseScore sheet music downloader";
        homepage = "https://github.com/mio-19/nurpkgs";
        license = lib.licenses.mit;
        mainProgram = "openscore";
        platforms = lib.platforms.linux ++ lib.platforms.darwin;
        sourceProvenance = [ lib.sourceTypes.fromSource ];
      };
    }
    // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
      buildPhase = ''
        runHook preBuild
        export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
        export PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
        export CFFIXED_USER_HOME=$HOME

        export REAL_DEV_DIR=/Applications/Xcode.app/Contents/Developer
        export FAKE_XCODE="$(pwd)/FakeXcode.app"
        export FAKE_DEV_DIR="$FAKE_XCODE/Contents/Developer"

        mkdir -p "$FAKE_DEV_DIR/usr/bin"
        ln -s /Applications/Xcode.app/Contents/Info.plist "$FAKE_XCODE/Contents/"
        ln -s /Applications/Xcode.app/Contents/version.plist "$FAKE_XCODE/Contents/"

        for file in "$REAL_DEV_DIR"/*; do
          if [[ "$(basename "$file")" != "usr" ]]; then
            ln -s "$file" "$FAKE_DEV_DIR/"
          fi
        done

        mkdir -p "$FAKE_DEV_DIR/usr"
        for file in "$REAL_DEV_DIR/usr"/*; do
          if [ "$(basename "$file")" != "bin" ]; then
            ln -s "$file" "$FAKE_DEV_DIR/usr/"
          fi
        done
        mkdir -p "$FAKE_DEV_DIR/usr/bin"
        for file in "$REAL_DEV_DIR/usr/bin"/*; do
          ln -s "$file" "$FAKE_DEV_DIR/usr/bin/"
        done

        rm -f "$FAKE_DEV_DIR/usr/bin/xcodebuild"
        cat << 'EOF2' > "$FAKE_DEV_DIR/usr/bin/xcodebuild"
        #!/bin/bash
        exec "$REAL_DEV_DIR/usr/bin/xcodebuild" ARCHS=$(uname -m) ONLY_ACTIVE_ARCH=YES -IDEPackageSupportDisableManifestSandbox=YES -IDEPackageSupportDisablePluginExecutionSandbox=YES "$@"
        EOF2
        chmod +x "$FAKE_DEV_DIR/usr/bin/xcodebuild"

        mkdir -p "$(pwd)/custom_bin"
        cat << 'EOF3' > "$(pwd)/custom_bin/rsync"
        #!/bin/bash
        /usr/bin/rsync "$@"
        status=$?
        if [[ "$status" == 0 ]]; then
          for arg in "$@"; do
            last_arg="$arg"
          done
          if [[ -d "$last_arg" ]]; then
            chmod -R u+w "$last_arg" || true
          fi
        fi
        exit $status
        EOF3
        chmod +x "$(pwd)/custom_bin/rsync"

        export DEVELOPER_DIR="$FAKE_DEV_DIR"
        export PATH="$(pwd)/custom_bin:$PATH"
        unset LD

        flutter build macos -v --release
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications $out/bin
        cp -r build/macos/Build/Products/Release/openscore.app $out/Applications/
        ln -s $out/Applications/openscore.app/Contents/MacOS/openscore $out/bin/openscore
        runHook postInstall
      '';

      sandboxProfile = ''
        (allow file-read* file-write* process-exec mach-lookup)
        (deny file-read* file-write* process-exec mach-lookup (subpath "/usr/local") (with no-log))
      '';
    }
  ))
  (
    old:
    lib.optionalAttrs stdenv.hostPlatform.isDarwin {
      __noChroot = true;
    }
  )
