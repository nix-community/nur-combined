{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "telemt";
  version = "3.4.11";

  src = fetchFromGitHub {
    owner = "telemt";
    repo = "telemt";
    rev = finalAttrs.version;
    hash = "sha256-jBspeSj8aRbHngK8bviVt/i1UiYUPRHSd8+7dnmJOQY=";
  };

  cargoHash = "sha256-x5/SLSlYeGx40oXj/I/5zvyTNgSBwKsA33OwVIq9LGw=";

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
