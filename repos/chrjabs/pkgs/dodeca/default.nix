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
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "bearcove";
    repo = "dodeca";
    tag = "v${version}";
    hash = "sha256-c6JQZLNOt4rmkNVlElALzl4Ph9+bzHpzesxUJDzM/QI=";
  };

  cargoHash = "sha256-mN+zt90vmUhiB1vKVepCYzhObTrIBT+uOh9Dhq1t/O8=";

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

    echo "Building ddc..."
    cargo build -j "$NIX_BUILD_CORES" --release -p dodeca

    echo "Building cells..."
    cargo build -j "$NIX_BUILD_CORES" --release \
        ${lib.strings.concatMapStringsSep " \\\n    " (
          cell: "-p cell-${cell} --bin ddc-cell-${cell}"
        ) cells}

    runHook postBuild
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cp "target/release/ddc" $out/bin/

    ${lib.strings.concatMapStringsSep "\n" (
      cell: "cp \"target/release/ddc-cell-${cell}\" $out/bin/"
    ) cells}

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
