{
  lib,
  rustPlatform,
  lld,
  wasm-tools,
}:

rustPlatform.buildRustPackage {
  pname = "hanga-mods";
  version = "0.1.0";

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    lld
    wasm-tools
  ];

  env.CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER = "wasm-ld";

  doCheck = false;

  # Host Cargo.toml stays crate-type = ["rlib"] so `cargo test -p urban_chaos`
  # does not emit a GNU-ld version-script (WIT exports contain ':').
  # `cargo rustc -- --crate-type cdylib` only passes wit-bindgen as .rmeta, so
  # patch crate-type here and let cargo link a real cdylib.
  # Unit tests must run on the rlib crate-type, before the wasm patch.
  buildPhase = ''
    runHook preBuild
    cargo test --offline --release -p urban_chaos -p testbed --lib -- --test-threads=1
    sed -i 's/crate-type = \[.*\]/crate-type = ["cdylib"]/' \
      mods/urban_chaos/Cargo.toml mods/testbed/Cargo.toml
    cargo build --offline --release --target wasm32-unknown-unknown \
      -p urban_chaos -p testbed
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/hanga/mods $out/share/hanga/games
    for name in urban_chaos testbed; do
      wasm-tools component new \
        "target/wasm32-unknown-unknown/release/$name.wasm" \
        -o "$out/share/hanga/mods/$name.wasm"
    done
    cp -a games/. $out/share/hanga/games/
    runHook postInstall
  '';

  meta = {
    description = "Hanga gameplay mods as wasmtime components";
    license = lib.licenses.mit;
  };
}
