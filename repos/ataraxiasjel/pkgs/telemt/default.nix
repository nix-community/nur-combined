{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "telemt";
  version = "3.5.14";

  src = fetchFromGitHub {
    owner = "telemt";
    repo = "telemt";
    rev = finalAttrs.version;
    hash = "sha256-g1X+9Do1N1q4IYvNAfPcboIuhb+eWgKncEE/Bad0F9g=";
  };

  cargoHash = "sha256-yRU2CQTIcrtZQWox4Htr95H3xyoT/Y9z6vwIPvpEhFA=";

  doCheck = false;

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
