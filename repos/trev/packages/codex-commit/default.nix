{
  buildRustPackage ? rustPlatform.buildRustPackage,
  lib,
  rustPlatform,
  fetchFromGitea,
}:

buildRustPackage (final: {
  pname = "codex-commit";
  version = "0.0.1";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "codex-commit";
    rev = "v${final.version}";
    hash = "sha256-j2pRL316IPoOeRnB2C4y0shJNbR126xK4mq7ku+tx1U=";
  };
  cargoHash = "sha256-iWBMNBZFnM7nC3eUug2hD6WCh/pcOCgqZgRpxRRNlds=";

  meta = {
    mainProgram = "codex-commit";
    description = "codex commit message generator";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    homepage = "https://trev.zip/llc/codex-commit";
    changelog = "https://trev.zip/llc/codex-commit/releases/tag/v${final.version}";
    downloadPage = "https://trev.zip/llc/codex-commit/releases/releases/tag/v${final.version}";
  };
})
