{ lib, flutter, rustPlatform, cargo, rustc, pkg-config, cmake, ninja, clang }:

flutter.buildFlutterApplication {
  pname = "uplink";
  version = "0.1.0";
  src = ./.;

  autoPubspecLock = ./pubspec.lock;

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    cargo rustc pkg-config cmake ninja rustPlatform.cargoSetupHook clang
  ];
  
  preBuild = ''
    mkdir -p .bin
    cp ./rustup-fake.sh .bin/rustup
    chmod +x .bin/rustup
    export PATH="$(pwd)/.bin:$PATH"
    
    # Copy rinf from pub cache to local directory and patch it
    RINF_PATH=$(grep '"name": "rinf"' .dart_tool/package_config.json -A 2 | grep rootUri | cut -d'"' -f4 | sed 's|^file://||')
    if [ -n "$RINF_PATH" ]; then
      echo "Patching rinf at $RINF_PATH"
      cp -r "$RINF_PATH" ./rinf_patched
      chmod -R +w ./rinf_patched
      
      cat << 'EOF' > ./rinf_patched/cargokit/run_build_tool.sh
#!/bin/sh
set -e
if [ "$1" = "build-cmake" ]; then
    MANIFEST="$CARGOKIT_MANIFEST_DIR/Cargo.toml"
    if [ "$CARGOKIT_CONFIGURATION" = "Release" ]; then
        cargo build --manifest-path "$MANIFEST" --release
    else
        cargo build --manifest-path "$MANIFEST"
    fi
    find /build -name libhub.so -exec cp {} "$CARGOKIT_OUTPUT_DIR/" \;
fi
EOF
      chmod +x ./rinf_patched/cargokit/run_build_tool.sh
      sed -i "s|$RINF_PATH|$(pwd)/rinf_patched|g" .dart_tool/package_config.json
    fi
  '';

  dontUseCmakeConfigure = true;

  meta = with lib; {
    description = "Uplink - Cross-platform pastebin GUI app";
    homepage = "https://github.com/example/uplink";
    license = licenses.mit;
    maintainers = [];
  };
}
