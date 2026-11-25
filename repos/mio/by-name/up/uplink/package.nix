{
  lib,
  stdenv,
  flutter,
  rustPlatform,
  cargo,
  rustc,
  pkg-config,
  cmake,
  ninja,
  clang,
  cocoapods,
  cacert,
  writableTmpDirAsHomeHook,
  callPackage,
  copyDesktopItems,
  makeDesktopItem,
  wrapGAppsHook3,
  gtk3,
  glib,
  pcre2,
}:

let
  buildFlutterApp = callPackage ./build-support/build-flutter-application.nix { };
in
lib.overrideDerivation
  (buildFlutterApp (
    {
      pname = "uplink";
      version = "0.1.0";
      src = ./.;

      targetFlutterPlatform = if stdenv.hostPlatform.isDarwin then "macos" else "linux";

      pubspecLock = lib.importJSON ./pubspec.lock.json;

      cargoDeps = rustPlatform.importCargoLock {
        lockFile = ./Cargo.lock;
      };

      nativeBuildInputs = [
        cargo
        rustc
        pkg-config
        cmake
        cacert
        ninja
        rustPlatform.cargoSetupHook
        clang
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        cocoapods
        writableTmpDirAsHomeHook
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

      preBuild = ''
            mkdir -p .bin
            cp ./rustup-fake.sh .bin/rustup
            chmod +x .bin/rustup
            
            # Fake sw_vers for flutter on macOS
            echo '#!/bin/sh' > .bin/sw_vers
            echo 'echo "ProductName: macOS"' >> .bin/sw_vers
            echo 'echo "ProductVersion: 13.0"' >> .bin/sw_vers
            echo 'echo "BuildVersion: 22A380"' >> .bin/sw_vers
            chmod +x .bin/sw_vers
            
            export PATH="$(pwd)/.bin:$PATH"
            
            # Copy rinf from pub cache to local directory and patch it
            RINF_PATH=$(grep '"name": "rinf"' .dart_tool/package_config.json -A 2 | grep rootUri | cut -d'"' -f4 | sed 's|^file://||')
            if [ -n "$RINF_PATH" ]; then
              echo "Patching rinf at $RINF_PATH"
              cp -r "$RINF_PATH" ./rinf_patched
              chmod -R +w ./rinf_patched
              
              mv ./rinf_patched/cargokit/run_build_tool.sh ./rinf_patched/cargokit/run_build_tool.orig.sh
              cat << 'EOF' > ./rinf_patched/cargokit/run_build_tool.sh
        #!/bin/sh
        set -ex
        if [ "$1" = "build-cmake" ]; then
            unset AWS_LC_SYS_USE_SYSTEM
            export AWS_LC_SYS_CMAKE_BUILDER=1
            MANIFEST="$CARGOKIT_MANIFEST_DIR/Cargo.toml"
            export CARGO_TARGET_DIR="$CARGOKIT_MANIFEST_DIR/../../target"
            if [ "$CARGOKIT_CONFIGURATION" = "Release" ]; then
                cargo build --manifest-path "$MANIFEST" --release
                cp -v "$CARGO_TARGET_DIR/release/libhub.so" "$CARGOKIT_OUTPUT_DIR/libhub.so"
            else
                cargo build --manifest-path "$MANIFEST"
                cp -v "$CARGO_TARGET_DIR/debug/libhub.so" "$CARGOKIT_OUTPUT_DIR/libhub.so"
            fi
        else
            exec "$(dirname "$0")/run_build_tool.orig.sh" "$@"
        fi
        EOF
              chmod +x ./rinf_patched/cargokit/run_build_tool.sh
              sed -i "s|$RINF_PATH|$(pwd)/rinf_patched|g" .dart_tool/package_config.json
            fi

            chmod -R u+w macos
      '';

      dontUseCmakeConfigure = true;
      dontCargoUseSystemLibs = true;

      # Fixup strips and re-signs Mach-O files, which would invalidate the
      # signatures the app bundle's build already applied.
      dontFixup = stdenv.hostPlatform.isDarwin;

      desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
        (makeDesktopItem {
          name = "uplink";
          exec = "uplink";
          icon = "uplink";
          desktopName = "Uplink";
          genericName = "Pastebin";
          comment = "Cross-platform pastebin GUI";
          categories = [
            "Network"
            "Utility"
          ];
          startupWMClass = "com.example.uplink";
        })
      ];

      postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
        install -Dm644 assets/icon.png $out/share/icons/hicolor/512x512/apps/uplink.png
      '';

      meta = with lib; {
        description = "Uplink - Cross-platform pastebin GUI app";
        homepage = "https://github.com/example/uplink";
        license = licenses.mit;
        mainProgram = "uplink";
        maintainers = [ ];
        platforms = platforms.unix;
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
        cp -r build/macos/Build/Products/Release/uplink.app $out/Applications/
        ln -s $out/Applications/uplink.app/Contents/MacOS/uplink $out/bin/uplink
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
