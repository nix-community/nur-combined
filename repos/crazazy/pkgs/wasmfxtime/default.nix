{ nvsrcs, wasmtime, rustPlatform }:
wasmtime.overrideAttrs (old: {
  inherit (nvsrcs.wasmfxtime) src version;
  
  cargoDeps = rustPlatform.importCargoLock nvsrcs.wasmfxtime.cargoLock."./Cargo.lock";
  meta = old.meta // {
    description = "wasmtime WebAssembly runner with support for delmited continuations";
  };
})
