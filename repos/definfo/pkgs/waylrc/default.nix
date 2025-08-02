{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "waylrc";
  version = "2.2.3-6";

  src = fetchFromGitHub {
    owner = "hafeoz";
    repo = "waylrc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-n9ExJei3cgrlINWhDCQP5KxTjanMkqLWP9SC8I5gKmY=";
  };

  cargoHash = "sha256-zYtRQ7KhG7z+FOaeT7juvgtsLCNlXW9GGXfgh4PXSHo=";

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
