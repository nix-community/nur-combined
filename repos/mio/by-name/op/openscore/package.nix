{
  lib,
  stdenv,
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
      # Fixup strips and re-signs Mach-O files, which would invalidate the
      # signatures the app bundle's build already applied.
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

        source ${../../../shared/darwin-xcode-shim.sh}
        fakeXcodeSetup

        export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
        export GIT_SSL_CAINFO="$SSL_CERT_FILE"

        # Nixpkgs sets LD=ld, which makes xcodebuild invoke ld directly while it
        # still passes -Xlinker flags meant for clang.
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
    _:
    lib.optionalAttrs stdenv.hostPlatform.isDarwin {
      __noChroot = true;
    }
  )
