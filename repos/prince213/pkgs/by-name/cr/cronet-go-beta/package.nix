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
  version = "154.0.8037.49-2-unstable-2026-10-23";

  src = previousAttrs.src.override {
    rev = "fa319c4f3b554bd7c647c6e0f18a7195ac1497a6";
    hash = "sha256-Vu6Xb3WpnX5n+eK8XbOOHOq1tzXKwPPsiZJGQ90KsSs=";
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
