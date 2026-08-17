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
    rev = "a3a736c781137759c64dac29b68c2f4b53ed9010";
    hash = "sha256-3lDSrDZuOM9sHS0qw0uWkRost/UYBdgGAwvy1ZrdxFc=";
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
