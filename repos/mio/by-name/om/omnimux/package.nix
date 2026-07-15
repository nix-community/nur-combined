{
  lib,
  stdenv,
  flutter,
  pkg-config,
  rustPlatform,
  cargo,
  rustc,
  cmake,
  ninja,
}:

let
  cargoDeps = rustPlatform.fetchCargoVendor {
    src = lib.cleanSource ./. ;
  sourceRoot = "source/src";
    hash = "sha256-eubJoDI2Q3mqofxseGnZDXuo/qsmGCcnP5dmWgqH8PQ=";
  };
in
flutter.buildFlutterApplication {
  pname = "omnimux";
  version = "0.1.0";
  pubspecLock = lib.importJSON ./src/pubspec.lock.json;

  src = lib.cleanSource ./. ;
  sourceRoot = "source/src";

  nativeBuildInputs = [
    pkg-config
    cargo
    rustc
    rustPlatform.cargoSetupHook
    cmake
    ninja
  ];

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
      echo "=== package_config.json after sed ==="
      cat .dart_tool/package_config.json | grep rinf -B 1 -A 2
      echo "======================================="
      cat << 'EOF2' > .rinf-writable/cargokit/run_build_tool.sh
#!/usr/bin/env bash
if [ "$1" == "build-cmake" ]; then
  cd "$CARGOKIT_MANIFEST_DIR"
  # cargoSetupHook has set up CARGO_HOME
  cargo build --release
  mkdir -p "$CARGOKIT_OUTPUT_DIR"
  # Find the built libhub.so since CARGO_TARGET_DIR might place it somewhere else
  find . -type f -name "libhub.so" -exec cp {} "$CARGOKIT_OUTPUT_DIR/libhub.so" \;
  find ../../target -type f -name "libhub.so" -exec cp {} "$CARGOKIT_OUTPUT_DIR/libhub.so" \;
fi
EOF2
      chmod +x .rinf-writable/cargokit/run_build_tool.sh || true
      patchShebangs .rinf-writable/cargokit/run_build_tool.sh || true
      # Also patch any occurrences of the old rinf path in generated cmake files
      find linux -name "generated_plugins.cmake" -exec sed -i "s|$RINF_PATH|$PWD/.rinf-writable/|g" {} +
    fi
  '';
}
