{
  lib,
  fetchFromGitHub,
  rustPlatform,

  # passthru
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aidoku-cli";
  version = "0-unstable-2026-08-16";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Aidoku";
    repo = "aidoku-rs";
    rev = "aaca5a1b12ad315f18195310b8af02011e300ded";
    hash = "sha256-o3QMXCQRvG+fvYgQsXk1P0UrpFxbQCbBIesM0W16Yuc=";
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
