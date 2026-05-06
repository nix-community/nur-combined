{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aidoku-cli";
  version = "0-unstable-2026-05-04";

  src = fetchFromGitHub {
    owner = "Aidoku";
    repo = "aidoku-rs";
    rev = "339b240f49d7d07e6fb77d722b53ab6bfce3961c";
    hash = "sha256-Anrn8zfKGSUbVjLL4uRJXTyPdxxyk0JJ+P0SoXcK8Gc=";
  };

  cargoHash = "sha256-6I/P/GJzttOHEOYrtkRUf7Mcuoj3fBr6ES1ZVByN7ZU=";

  buildAndTestSubdir = "crates/cli";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Command-line utility for Aidoku source development and testing";
    homepage = "https://github.com/Aidoku/aidoku-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "aidoku";
  };
})
