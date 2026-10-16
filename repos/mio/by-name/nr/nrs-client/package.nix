{
  lib,
  stdenv,
  callPackage,
  flutter,
  rustPlatform,
  pkg-config,
  cacert,
  sysprof ? null,
  gtk3 ? null,
  glib ? null,
  cocoapods ? null,
  writableTmpDirAsHomeHook ? null,
}:

let
  buildFlutterApp = callPackage ./build-support/build-flutter-application.nix { };
  hub = rustPlatform.buildRustPackage {
    pname = "nrs-client-hub";
    version = "1.0.0";
    src = ./src/native/hub;
    cargoLock.lockFile = ./src/native/hub/Cargo.lock;
  };
in
lib.overrideDerivation
  (buildFlutterApp (
    {
      pname = "nrs-client";
      version = "1.0.0";
      src = ./src;
      pubspecLock = lib.importJSON ./src/pubspec.lock.json;
      gitHashes = { };

      targetFlutterPlatform = if stdenv.hostPlatform.isDarwin then "macos" else "linux";

      nativeBuildInputs = [
        pkg-config
        cacert
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        sysprof
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        cocoapods
        writableTmpDirAsHomeHook
      ];

      buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
        gtk3
        glib
      ];

      preBuild =
        if stdenv.hostPlatform.isDarwin then
          ''
                    mkdir -p .bin
                    echo '#!/bin/sh' > .bin/sw_vers
                    echo 'echo "ProductName: macOS"' >> .bin/sw_vers
                    echo 'echo "ProductVersion: 15.0"' >> .bin/sw_vers
                    echo 'echo "BuildVersion: 24A348"' >> .bin/sw_vers
                    chmod +x .bin/sw_vers
                    export PATH="$(pwd)/.bin:$PATH"

                    RINF_PATH=$(grep '"name": "rinf"' .dart_tool/package_config.json -A 2 | grep rootUri | cut -d'"' -f4 | sed 's|^file://||')
                    if [ -n "$RINF_PATH" ]; then
                      echo "Patching rinf at $RINF_PATH"
                      cp -r "$RINF_PATH" ./rinf_patched
                      chmod -R +w ./rinf_patched

                      cat << 'EOF' > ./rinf_patched/cargokit/run_build_tool.sh
            #!/bin/sh
            set -ex
            if [ "$1" = "build-pod" ]; then
                mkdir -p "$BUILT_PRODUCTS_DIR"
                cp -v "${hub}/lib/libhub.a" "$BUILT_PRODUCTS_DIR/libhub.a"
                exit 0
            fi
            EOF
                      chmod +x ./rinf_patched/cargokit/run_build_tool.sh
                      sed -i "s|$RINF_PATH|$(pwd)/rinf_patched|g" .dart_tool/package_config.json
                    fi

                    chmod -R u+w macos
          ''
        else
          ''
            export PREBUILT_HUB_LIB="${hub}/lib/libhub.so"
          '';

      dontFixup = stdenv.hostPlatform.isDarwin;

      extraWrapProgramArgs = lib.optionalString stdenv.hostPlatform.isLinux "--prefix LD_LIBRARY_PATH : $out/app/nrs-client/lib";

      meta = {
        description = "Client for the Australian National Relay Service (NRS) and New Zealand Relay (NZ Relay) built with Flutter and Rinf";
        homepage = "https://nrschat.nrscall.gov.au/nrs/internetrelay";
        license = lib.licenses.mit;
        platforms = lib.platforms.linux ++ lib.platforms.darwin;
        mainProgram = "nrs_client";
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

        export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
        export GIT_SSL_CAINFO="${cacert}/etc/ssl/certs/ca-bundle.crt"

        unset LD

        flutter build macos -v --release
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications $out/bin
        cp -r build/macos/Build/Products/Release/nrs_client.app $out/Applications/
        ln -s $out/Applications/nrs_client.app/Contents/MacOS/nrs_client $out/bin/nrs_client
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
