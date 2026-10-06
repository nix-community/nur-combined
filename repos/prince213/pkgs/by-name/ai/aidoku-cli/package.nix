{
  lib,
  fetchFromGitHub,
  rustPlatform,

  # passthru
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aidoku-cli";
  version = "0-unstable-2026-10-06";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Aidoku";
    repo = "aidoku-rs";
    rev = "ae6485e3c14ecd1fd5497d170eae884c68d04a87";
    hash = "sha256-GDgoscsdxBmWx0MyM6tSjzlEastsp8CDuBT3+qIVEtw=";
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
