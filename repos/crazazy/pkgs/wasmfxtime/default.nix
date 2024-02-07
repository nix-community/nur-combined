{ nvsrcs, wasmtime }:
wasmtime.overrideAttrs (old: {
  inherit (nvsrcs.wasmfxtime) src version;
  meta = old.meta // {
    description = "wasmtime WebAssembly runner with support for delmited continuations";
  };
})
