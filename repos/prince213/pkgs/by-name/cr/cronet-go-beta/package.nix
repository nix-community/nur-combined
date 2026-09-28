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
  version = "154.0.8037.49-2-unstable-2026-09-25";

  src = previousAttrs.src.override {
    rev = "1159fbf94b5fa6fcc95bd363fbcad061d5898acc";
    hash = "sha256-DE1Rm6HC2wHg/0HWQrc33l/BPD5aGX1/GoHXPN3Z7Gw=";
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
