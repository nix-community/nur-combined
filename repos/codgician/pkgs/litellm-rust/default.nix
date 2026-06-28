{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "litellm-rust";
  version = "0-unstable-2026-06-25";

  src = fetchFromGitHub {
    owner = "LiteLLM-Labs";
    repo = "litellm-rust";
    rev = "76f83257fce4dcc3d76e7e760934bbd725b624d9";
    hash = "sha256-ZiVHTUPVYSyR8w3OBxle8GBuJ2/QzB7Xqe9Zwj/NfKA=";
  };

  cargoHash = "sha256-xYKuy3L+58xVGuJCDyP2Qc33DLO7tokg2Gh+HaLp2D8=";

  # The integration tests under `tests/` spin up `wiremock::MockServer`
  # instances and exercise the managed-agents flows against a live Postgres
  # database, neither of which is available inside the Nix build sandbox.
  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch=main"
    ];
  };

  meta = {
    description = "Minimal Rust gateway built for coding agents (LiteLLM-compatible)";
    homepage = "https://github.com/LiteLLM-Labs/litellm-rust";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "lite";
  };
})
