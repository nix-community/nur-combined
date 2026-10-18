{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-18";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "af69cf5e5305dc141258713b939e1c0f32744f26";
    hash = "sha256-I+56vwEdmJet+qdkWqk+b6OAMUHk4Z4NH4ZELVF6xMw=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-rKqgrwpaALGnsR4VMbos77mDfWfkannhPRUEs8KuFXQ=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Unifies the management of LLM APIs across multiple backend services";
    homepage = "https://github.com/yym68686/uni-api";
    license = lib.licenses.unfree;
    mainProgram = "uni-api-front";
  };
})
