{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "litellm-rust";
  version = "0-unstable-2026-06-02";

  src = fetchFromGitHub {
    owner = "LiteLLM-Labs";
    repo = "litellm-rust";
    rev = "265cb16f6bb324af91c68416e068735260af6ad3";
    hash = "sha256-fUibxBb1hhfue/HKnrUZZIWzJzfdmEwOgJyNXSJbsdk=";
  };

  cargoHash = "sha256-Au4L0yr0Ukv/t19tIwogeODKMS/410xLl4MlHQktKAo=";

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
