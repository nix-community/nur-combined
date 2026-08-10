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
  pnpm,
  writableTmpDirAsHomeHook,
  binaryen,
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

  cells = [
    "code-execution"
    "css"
    "data"
    "dialoguer"
    "fonts"
    "gingembre"
    "html"
    "html-diff"
    "http"
    "image"
    "js"
    "jxl"
    "linkcheck"
    "markdown"
    "minify"
    "sass"
    "svgo"
    "term"
    "tui"
    "vite"
    "webp"
  ];
in
rustPlatform.buildRustPackage rec {
  pname = "dodeca";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "bearcove";
    repo = "dodeca";
    tag = "v${version}";
    hash = "sha256-W6wiqbVE0HUPD/dTtE3v9vJxruVoXt3nDhcP1g5/xjc=";
  };

  cargoHash = "sha256-jhIhgO+ccrqIJzWti/C4MmVF5Mqslebut2hjTkHSFJ8=";

  patches = [
    ./fix-duplicate-wasm-log.patch
  ];

  buildInputs = [ openssl ];
  nativeBuildInputs = [
    wasm-pack
    wasm-bindgen-cli
    rustc.llvmPackages.lld
    pkg-config
    cmake
    pnpm
    writableTmpDirAsHomeHook
    binaryen
  ];

  buildPhase = ''
    runHook preBuild

    echo "Building WASM..."
    wasm-pack build --target web crates/dodeca-devtools
    wasm-pack build --target web crates/dodeca-search-wasm

    echo "Building dodeca workspace..."
    cargo build -j "$NIX_BUILD_CORES" --release
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cp "target/release/ddc" $out/bin/

    mkdir -p $out/devtools
    cp -R crates/dodeca-devtools/pkg $out/devtools/

    runHook postInstall
  '';

  meta = {
    description = "A query-system-based static site generator";
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
