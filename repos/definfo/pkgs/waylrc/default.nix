{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "waylrc";
  version = "2.2.4";

  src = fetchFromGitHub {
    owner = "hafeoz";
    repo = "waylrc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lDuTyeGViaT7dcxJXh9Lip9GIG78sWgNb6Eiddsxbr0=";
  };

  cargoHash = "sha256-sZA/t5MLxXxfG+3c6IdJTfBSNZx7iRViUgTQbKeSCwM=";

  RUSTC_BOOTSTRAP = 1; # waylrc requires nightly feature

  meta = {
    description = "An addon for waybar to display lyrics";
    homepage = "https://github.com/hafeoz/waylrc";
    license = with lib.licenses; [
      bsd0
      cc0
      wtfpl
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ definfo ];
  };
})
