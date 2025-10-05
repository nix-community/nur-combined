{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "adsb_deku";
  version = "2025.05.03";

  src = fetchFromGitHub {
    owner = "rsadsb";
    repo = "adsb_deku";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MmCaH9SNxuDLOJGd/lc68fYnZyg01S7m9u9cVQxmBTw=";
  };

  cargoHash = "sha256-w5/nDcrWG6v3iIvXvEKc1O0F9WBx+5oFnGLqK39u5mQ=";

  meta = {
    description = "Rust ADS-B decoder + tui radar application";
    homepage = "https://github.com/rsadsb/adsb_deku";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
