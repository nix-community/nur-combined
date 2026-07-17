{
  lib,
  flutter,
  pkg-config,
  rustPlatform,
  cargo,
  rustc,
  cmake,
  ninja,
  cocoapods,
  cacert,
  stdenv,
}:

let
  cargoDeps = rustPlatform.fetchCargoVendor {
    src = lib.cleanSource ./.;
    sourceRoot = "source/src";
    hash = "sha256-CONAxDzeGOLoFWBZuJA7dwvmJEMkwG3+fdE64OTuSOo=";
  };
in
flutter.buildFlutterApplication (
  {
    pname = "omnimux";
    version = "0.1.0";
    pubspecLock = lib.importJSON ./src/pubspec.lock.json;

    src = lib.cleanSource ./.;
    sourceRoot = "source/src";
    pubCacheHash = "sha256-1111111111111111111111111111111111111111111=";

    targetFlutterPlatform = "linux"; # bypass nixpkgs check

    # Allow macOS to use the host's Xcode (requires sandbox = false in nix.conf)

    nativeBuildInputs = [
      pkg-config
      cargo
      rustc
      rustPlatform.cargoSetupHook
      cmake
      ninja
      cacert
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      cocoapods
    ];

    # Intentional: do not wrap with tmux/openssh — use the ones from PATH.
    cargoRoot = ".";
    dontUseCmakeConfigure = true;
    inherit cargoDeps;

    preBuild = ''
          # Make rinf writable so cargokit can chmod +x
          # Find the path to rinf in the package_config.json
          RINF_PATH=$(grep '"name": "rinf"' -A 3 .dart_tool/package_config.json | grep rootUri | cut -d '"' -f 4 | sed 's|^file://||')
          if [ -n "$RINF_PATH" ]; then
            cp -r "$RINF_PATH" .rinf-writable
            chmod -R +w .rinf-writable
            sed -i 's|"rootUri": ".*rinf.*"|"rootUri": "file://'"$PWD"'/.rinf-writable"|g' .dart_tool/package_config.json
            cat << 'EOF2' > .rinf-writable/cargokit/run_build_tool.sh
      #!/usr/bin/env bash
      cd "$CARGOKIT_MANIFEST_DIR"
      cargo build --release
      mkdir -p "$CARGOKIT_OUTPUT_DIR"
      find . -type f -name "libhub.so" -exec cp {} "$CARGOKIT_OUTPUT_DIR/libhub.so" \; || true
      find ../../target -type f -name "libhub.so" -exec cp {} "$CARGOKIT_OUTPUT_DIR/libhub.so" \; || true
      # For macOS:
      find . -type f -name "libhub.dylib" -exec cp {} "$CARGOKIT_OUTPUT_DIR/libhub.dylib" \; || true
      find ../../target -type f -name "libhub.dylib" -exec cp {} "$CARGOKIT_OUTPUT_DIR/libhub.dylib" \; || true
      find . -type f -name "libhub.a" -exec cp {} "$CARGOKIT_OUTPUT_DIR/libhub.a" \; || true
      find ../../target -type f -name "libhub.a" -exec cp {} "$CARGOKIT_OUTPUT_DIR/libhub.a" \; || true
      EOF2
            chmod +x .rinf-writable/cargokit/run_build_tool.sh || true
            patchShebangs .rinf-writable/cargokit/run_build_tool.sh || true
            # Also patch any occurrences of the old rinf path in generated cmake files
            find . -name "generated_plugins.cmake" -exec sed -i "s|$RINF_PATH|$PWD/.rinf-writable/|g" {} + || true
          fi
    '';

    postInstall = ''
      mkdir -p $out/share/icons/hicolor/256x256/apps
      cp assets/icon.png $out/share/icons/hicolor/256x256/apps/omnimux.png
      mkdir -p $out/share/applications
      cat << EOF > $out/share/applications/omnimux.desktop
      [Desktop Entry]
      Name=Omnimux
      Exec=$out/bin/omnimux
      Icon=omnimux
      Type=Application
      Categories=Utility;
      EOF
    '';

    meta = {
      description = "Multi-tab terminal UI for local and remote tmux sessions";
      mainProgram = "omnimux";
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
    };
  }
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    __noChroot = true;
    buildPhase = ''
      runHook preBuild
      export HOME=$NIX_BUILD_TOP
      export CFFIXED_USER_HOME=$NIX_BUILD_TOP
      export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
      export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

      # Create a shadow flutter SDK to make FlutterMacOS.xcframework writable
      export FAKE_FLUTTER_ROOT=$NIX_BUILD_TOP/fake_flutter
      mkdir -p $FAKE_FLUTTER_ROOT
      # Create directory structure and symlink files
      cp -rs ${flutter}/* $FAKE_FLUTTER_ROOT/
      chmod -R u+w $FAKE_FLUTTER_ROOT

      for ENGINE_DIR in darwin-x64 darwin-x64-release; do
        FRAMEWORK_DIR="$FAKE_FLUTTER_ROOT/bin/cache/artifacts/engine/$ENGINE_DIR/FlutterMacOS.xcframework"
        if [ -d "$FRAMEWORK_DIR" ]; then
          rm -rf "$FRAMEWORK_DIR"
          REAL_XCFRAMEWORK=$(readlink -f ${flutter}/bin/cache/artifacts/engine/$ENGINE_DIR/FlutterMacOS.xcframework)
          cp -a "$REAL_XCFRAMEWORK" "$FRAMEWORK_DIR"
          chmod -R u+w "$FRAMEWORK_DIR"
        fi
      done

      export PATH=$FAKE_FLUTTER_ROOT/bin:$PATH
      export FLUTTER_ROOT=$FAKE_FLUTTER_ROOT

      # Create a wrapper for codesign to use the native macOS codesign
      mkdir -p $NIX_BUILD_TOP/bin
      cat << 'EOF' > $NIX_BUILD_TOP/bin/codesign
      #!/usr/bin/env bash
      exec /usr/bin/codesign "$@"
      EOF
      chmod +x $NIX_BUILD_TOP/bin/codesign
      export PATH=$NIX_BUILD_TOP/bin:$PATH

      mkdir -p build/flutter_assets/fonts

      # Unset Nix compiler variables to prevent xcodebuild from using raw `ld` instead of `clang` for linking
      unset CC CXX LD AR AS RANLIB NM STRIP

      flutter config --no-enable-swift-package-manager
      flutter build macos -v --release
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -r build/macos/Build/Products/Release/*.app $out/Applications/omnimux.app
      mkdir -p $out/bin
      
      # Find the executable inside MacOS directory
      EXEC_NAME=$(ls $out/Applications/omnimux.app/Contents/MacOS/ | head -n 1)
      ln -s $out/Applications/omnimux.app/Contents/MacOS/$EXEC_NAME $out/bin/omnimux
      
      mkdir -p $debug
      runHook postInstall
    '';
  }
)
