{ nvsrcs, wasmtime, rustPlatform }:
rustPlatform.buildRustPackage {
  inherit (nvsrcs.wasmfxtime) src version;
  inherit (wasmtime) pname cargoBuildFlags outputs doCheck postInstall;

  cargoLock = nvsrcs.wasmfxtime.cargoLock."./Cargo.lock";
  meta = wasmtime.meta // {
    description = "wasmtime WebAssembly runner with support for delmited continuations";
  };
}
