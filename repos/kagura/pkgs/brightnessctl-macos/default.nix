{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "brightnessctl-macos";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "icewithcola";
    repo = "brightnessctl-macos";
    rev = "b17816adf7aa6adb2050dea2be8afde2451922b3";
    hash = "sha256-/56wY6lmZKGTRV3N9KkzNnMHS/N6/PIovYl5iE7XUvI=";
  };

  cargoHash = "sha256-d3yCCOW1r/bgn22r7Nn9BomB5EExtV1DDgIiM+O8LX4=";

  meta = {
    description = "brightnessctl-style DDC/CI monitor control for macOS";
    homepage = "https://github.com/icewithcola/brightnessctl-macos";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
  };
}
