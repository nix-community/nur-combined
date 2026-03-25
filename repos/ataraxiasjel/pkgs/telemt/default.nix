{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "telemt";
  version = "3.3.31";

  src = fetchFromGitHub {
    owner = "telemt";
    repo = "telemt";
    rev = finalAttrs.version;
    hash = "sha256-SN0iWCbGZU5ke0YyVHWCih0oK4/9frLez6PZ0KBLT3s=";
  };

  cargoHash = "sha256-6JEzpmtXh1e3Gh7awLnZhiRHzB8+bFqD21imYL5wyqw=";

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
