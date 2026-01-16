{
  lib,
  stdenv,
  rustPlatform,
  rustc,
  fetchFromGitHub,
  wasm-pack,
  pkg-config,
  openssl,
  cmake,
  buildWasmBindgenCli,
  fetchCrate,
}:
let
  wasm-bindgen-cli = buildWasmBindgenCli rec {
    src = fetchCrate {
      pname = "wasm-bindgen-cli";
      version = "0.2.108";
      hash = "sha256-UsuxILm1G6PkmVw0I/JF12CRltAfCJQFOaT4hFwvR8E=";
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit src;
      inherit (src) pname version;
      hash = "sha256-iqQiWbsKlLBiJFeqIYiXo3cqxGLSjNM8SOWXGM9u43E=";
    };
  };
in
rustPlatform.buildRustPackage rec {
  pname = "dodeca";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "bearcove";
    repo = "dodeca";
    rev = "v${version}";
    hash = "sha256-sd1Pyq1FFVJfP6gUXstOGBQ/0Wl/leEnenJZjMkejw0=";
  };

  patches = [
    ./fix-wasm-symbols.patch
  ];

  cargoHash = "sha256-4r2341EeSZGUJ5fbaixPdVzUQGrtvSnQfojC2GWKvT0=";

  cargoPatches = [
    ./patch-dependencies.patch
  ];

  buildInputs = [ openssl ];
  nativeBuildInputs = [
    wasm-pack
    wasm-bindgen-cli
    rustc.llvmPackages.lld
    pkg-config
    cmake
  ];

  buildPhase = ''
    runHook preBuild

    echo "Building WASM..."
    cargo build -j "$NIX_BUILD_CORES" -p dodeca-devtools --target wasm32-unknown-unknown --release
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

    echo "Building cells..."
    cargo build -j "$NIX_BUILD_CORES" --release \
        -p cell-code-execution --bin ddc-cell-code-execution \
        -p cell-css --bin ddc-cell-css \
        -p cell-dialoguer --bin ddc-cell-dialoguer \
        -p cell-fonts --bin ddc-cell-fonts \
        -p cell-gingembre --bin ddc-cell-gingembre \
        -p cell-html --bin ddc-cell-html \
        -p cell-html-diff --bin ddc-cell-html-diff \
        -p cell-http --bin ddc-cell-http \
        -p cell-image --bin ddc-cell-image \
        -p cell-js --bin ddc-cell-js \
        -p cell-jxl --bin ddc-cell-jxl \
        -p cell-linkcheck --bin ddc-cell-linkcheck \
        -p cell-markdown --bin ddc-cell-markdown \
        -p cell-minify --bin ddc-cell-minify \
        -p cell-sass --bin ddc-cell-sass \
        -p cell-svgo --bin ddc-cell-svgo \
        -p cell-tui --bin ddc-cell-tui \
        -p cell-webp --bin ddc-cell-webp

    runHook postBuild
  '';

  doCheck = false;

  installPhase =
    let
      libExt = if stdenv.isDarwin then "dylib" else "so";
    in
    ''
      runHook preInstall

      mkdir -p $out/bin

      cp "target/release/ddc" $out/bin/


      cp "target/release/ddc-cell-code-execution" $out/bin/
      cp "target/release/ddc-cell-css" $out/bin/
      cp "target/release/ddc-cell-dialoguer" $out/bin/
      cp "target/release/ddc-cell-fonts" $out/bin/
      cp "target/release/ddc-cell-gingembre" $out/bin/
      cp "target/release/ddc-cell-html" $out/bin/
      cp "target/release/ddc-cell-html-diff" $out/bin/
      cp "target/release/ddc-cell-http" $out/bin/
      cp "target/release/ddc-cell-image" $out/bin/
      cp "target/release/ddc-cell-js" $out/bin/
      cp "target/release/ddc-cell-jxl" $out/bin/
      cp "target/release/ddc-cell-linkcheck" $out/bin/
      cp "target/release/ddc-cell-markdown" $out/bin/
      cp "target/release/ddc-cell-minify" $out/bin/
      cp "target/release/ddc-cell-sass" $out/bin/
      cp "target/release/ddc-cell-svgo" $out/bin/
      cp "target/release/ddc-cell-tui" $out/bin/
      cp "target/release/ddc-cell-webp" $out/bin/

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
    broken = !lib.versionAtLeast rustc.version "1.91";
  };
}
