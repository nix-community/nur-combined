{
  lib,
  cronet-go,
  replaceVars,
  stdenvNoCC,

  # buildInputs
  darwin,
}:

cronet-go.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "154.0.8037.49-2-unstable-2026-11-26";

  src = previousAttrs.src.override {
    rev = "e265295f7be0bc2209ec36078028667e6b9c217e";
    hash = "sha256-3rxR8bRsh0EJQJ6fqVOS/7E+OO001b9BvQM1Q7QdIyM=";
  };

  patches = [
    ./cflags.patch
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isDarwin (
    replaceVars ./libresolv.patch {
      libresolv = lib.getInclude darwin.libresolv;
    }
  );
})
