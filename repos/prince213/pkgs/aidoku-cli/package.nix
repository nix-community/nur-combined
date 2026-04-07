{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aidoku-cli";
  version = "0-unstable-2026-03-06";

  src = fetchFromGitHub {
    owner = "Aidoku";
    repo = "aidoku-rs";
    rev = "59788187c937bbf960a8f1eb2b4d4e86a5a75a21";
    hash = "sha256-itIwJ56dE3OHG8+c+7h1ljNCvLqLOJjogtdCpzgjU0g=";
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
