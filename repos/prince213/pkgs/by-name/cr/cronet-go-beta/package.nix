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
  version = "154.0.8037.49-2-unstable-2026-09-29";

  src = previousAttrs.src.override {
    rev = "abcdebebd23da6e74cf9c55ab63024ce66fc0f7b";
    hash = "sha256-d+Cabf/ibbk9whmrAkLczS2Bt2SltfaX/vm4hVSlr/o=";
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
