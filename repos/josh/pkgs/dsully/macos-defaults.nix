{
  lib,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:
rustPlatform.buildRustPackage rec {
  pname = "macos-defaults";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "dsully";
    repo = "macos-defaults";
    rev = version;
    hash = "sha256-dSZjMuw7ott0dgiYo0rqekEvScmrX6iG7xHaPAgo1/E=";
  };

  cargoHash = "sha256-xSg6WAkFPS8B1G4WqMW77egCMmOEo3rK2EKcrDYaBjA=";
  useFetchCargoVendor = true;

  doCheck = false;

  __structuredAttrs = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "A tool for managing macOS defaults declaratively via YAML files.";
    homepage = "https://github.com/dsully/macos-defaults";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "macos-defaults";
  };
}
