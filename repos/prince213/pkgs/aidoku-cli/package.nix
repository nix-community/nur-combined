{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aidoku-cli";
  version = "0-unstable-2026-04-07";

  src = fetchFromGitHub {
    owner = "Aidoku";
    repo = "aidoku-rs";
    rev = "401296e54610f938beac4102b564ae11db4b3aed";
    hash = "sha256-vVU/ReOlc1Q+sNhV+JM+pZ7VlnBfZOKA6sCDlSHJnzA=";
  };

  cargoHash = "sha256-vawbjRjIOOUbkvSUCbO1TuJfGIyXJjHlkFPdF+59ZE8=";

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
