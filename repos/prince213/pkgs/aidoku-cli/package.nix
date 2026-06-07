{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aidoku-cli";
  version = "0-unstable-2026-05-31";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Aidoku";
    repo = "aidoku-rs";
    rev = "a0624d4b899fbec54a6ad99400a18ec9202ea9d3";
    hash = "sha256-BlCbc57yqFM9br54BPFibKlk3w0MTaIWiXoH4HEuSFI=";
  };

  cargoHash = "sha256-zA9UgryFsJhuTZfquDj7sIC1Omjuy8WWdc5uwWIx2UY=";

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
