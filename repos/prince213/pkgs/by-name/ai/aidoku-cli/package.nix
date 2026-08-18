{
  lib,
  fetchFromGitHub,
  rustPlatform,

  # passthru
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aidoku-cli";
  version = "0-unstable-2026-08-18";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Aidoku";
    repo = "aidoku-rs";
    rev = "a386ee40ab79896549bb9514657ea957e6625be5";
    hash = "sha256-GtaAdu5nRExiwHDxOUpkNHyCbId4zcaBpBfUk3UoCUE=";
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
