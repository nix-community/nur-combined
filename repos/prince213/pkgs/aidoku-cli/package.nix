{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aidoku-cli";
  version = "0-unstable-2026-02-15";

  src = fetchFromGitHub {
    owner = "Aidoku";
    repo = "aidoku-rs";
    rev = "b4c424921c094268556a2766e7277aa46c08d6c6";
    hash = "sha256-Byb1SOiycipdJKMtkmhSB+RvnH3L/qAhpZVBq8GgcSU=";
  };

  cargoHash = "sha256-vawbjRjIOOUbkvSUCbO1TuJfGIyXJjHlkFPdF+59ZE8=";

  buildAndTestSubdir = "crates/cli";

  meta = {
    description = "Command-line utility for Aidoku source development and testing";
    homepage = "https://github.com/Aidoku/aidoku-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "aidoku";
  };
})
