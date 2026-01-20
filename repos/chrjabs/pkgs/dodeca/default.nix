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
      version = "0.2.106";
      hash = "sha256-M6WuGl7EruNopHZbqBpucu4RWz44/MSdv6f0zkYw+44=";
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit src;
      inherit (src) pname version;
      hash = "sha256-ElDatyOwdKwHg3bNH/1pcxKI7LXkhsotlDPQjiLHBwA=";
    };
  };

  cells = [
    "code-execution"
    "css"
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
    "webp"
  ];
in
rustPlatform.buildRustPackage rec {
  pname = "dodeca";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "bearcove";
    repo = "dodeca";
    tag = "v${version}";
    hash = "sha256-O5TisKCGyA9MS0I4zD3l9JXQytosxQKlJfoG+pOZL7k=";
  };

  patches = [
    ./fix-wasm-symbols.patch
  ];

  cargoHash = "sha256-FrV6rUaUfi6g4+4eTmw67uoeRommY8Sed5dfkgBjqvU=";

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

  installPhase =
    let
      libExt = if stdenv.isDarwin then "dylib" else "so";
    in
    ''
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
