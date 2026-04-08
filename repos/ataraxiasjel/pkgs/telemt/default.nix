{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "telemt";
  version = "3.3.39";

  src = fetchFromGitHub {
    owner = "telemt";
    repo = "telemt";
    rev = finalAttrs.version;
    hash = "sha256-HTerDyqfTqC2x2BN/NjLkSLqSsAQHbecdJjpIAIfHqs=";
  };

  cargoHash = "sha256-cW5iVcUg3wnOfpN9CY89FCSObgZlbu55L4V9C4qPjJo=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "MTProxy for Telegram on Rust + Tokio";
    homepage = "https://github.com/telemt/telemt";
    license = licenses.unfree;
    mainProgram = "telemt";
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = platforms.linux;
  };
})
