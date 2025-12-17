{
  lib,
  stdenv,
  rustPlatform,
  rustc,
  fetchFromGitHub,
  wasm-pack,
  wasm-bindgen-cli_0_2_105 ? null,
  pkg-config,
  openssl,
  cmake,
}:
rustPlatform.buildRustPackage rec {
  pname = "dodeca";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "bearcove";
    repo = "dodeca";
    rev = "v${version}";
    hash = "sha256-r25YTH/nRWgIBlFiw8cTpcUEpV6QmOsxdPa2UOd/w0M=";
  };

  cargoHash = "sha256-XSWCLgefQRqnhLuOn1qv5stmjQgoj2915e8gTORJQb0=";

  cargoPatches = [
    ./make-build-work.patch
  ];

  buildInputs = [ openssl ];
  nativeBuildInputs = [
    wasm-pack
    wasm-bindgen-cli_0_2_105
    rustc.llvmPackages.lld
    pkg-config
    cmake
  ];

  buildPhase = ''
    runHook preBuild

    echo "Building WASM..."
    cargo build -j "$NIX_BUILD_CORES" -p livereload-client -p dodeca-devtools --target wasm32-unknown-unknown --release
    wasm-bindgen --target web --out-dir crates/livereload-client/pkg target/wasm32-unknown-unknown/release/livereload_client.wasm
    wasm-bindgen --target web --out-dir crates/dodeca-devtools/pkg target/wasm32-unknown-unknown/release/dodeca_devtools.wasm

    # Auto-discover plugins (crates with cdylib in Cargo.toml)
    PLUGINS=()
    for dir in crates/dodeca-*/; do
        if [[ -f "$dir/Cargo.toml" ]] && grep -q 'cdylib' "$dir/Cargo.toml"; then
            plugin=$(basename "$dir")
            PLUGINS+=("$plugin")
        fi
    done

    echo "Building ddc..."
    cargo build -j "$NIX_BUILD_CORES" --release -p dodeca

    # Build plugins
    echo "Building plugins..."
    PLUGIN_ARGS=""
    for plugin in "''${PLUGINS[@]}"; do
        PLUGIN_ARGS="$PLUGIN_ARGS -p $plugin"
    done
    cargo build -j "$NIX_BUILD_CORES" --release $PLUGIN_ARGS

    runHook postBuild
  '';

  doCheck = false;

  installPhase =
    let
      libExt = if stdenv.isDarwin then "dylib" else "so";
    in
    ''
      runHook preInstall

      # Auto-discover plugins (crates with cdylib in Cargo.toml)
      PLUGINS=()
      for dir in crates/dodeca-*/; do
          if [[ -f "$dir/Cargo.toml" ]] && grep -q "cdylib" "$dir/Cargo.toml"; then
              plugin=$(basename "$dir")
              # Convert crate name to lib name (dodeca-foo -> dodeca_foo)
              lib_name="''${plugin//-/_}"
              PLUGINS+=("$lib_name")
          fi
      done

      mkdir -p $out/bin/plugins
      cp "target/release/ddc" $out/bin/
      # Copy plugins
      for plugin in "''${PLUGINS[@]}"; do
          PLUGIN_FILE="lib$plugin.${libExt}"
          SRC="target/release/$PLUGIN_FILE"
          if [[ -f "$SRC" ]]; then
              cp "$SRC" $out/bin/plugins/
          else
              echo "Warning: Plugin not found: $SRC"
          fi
      done

      runHook postInstall
    '';

  meta = {
    description = "A salsa-infused static site generator ";
    homepage = "https://dodeca.bearcove.eu/";
    changelog = "github.com/bearcove/dodeca/blob/${src.rev}/CHANGELOG.md";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
    mainProgram = "ddc";
    # MSRV is 1.91
    broken = !lib.versionAtLeast rustc.version "1.91" || (wasm-bindgen-cli_0_2_105 == null);
  };
}
