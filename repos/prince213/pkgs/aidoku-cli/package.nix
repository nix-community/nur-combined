{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aidoku-cli";
  version = "0-unstable-2026-05-08";

  src = fetchFromGitHub {
    owner = "Aidoku";
    repo = "aidoku-rs";
    rev = "4c2e2585d1557fc1f9c4c96298446d024f308ee6";
    hash = "sha256-ZudsgI8Weqygsu9S1e1+xXHCoaGGdSHdBkTlQ7FLdNY=";
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
