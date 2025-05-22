{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage {
  pname = "rwds-cli";
  version = "0-unstable-2025-04-29";

  src = fetchFromGitHub {
    owner = "dtomvan";
    repo = "rusty-words";
    rev = "b21a88079a869a8a3b7fe36a45c4665f7b38a097";
    hash = "sha256-fkjcUz54knC3WY/ub05GRAM3pGqyZHe65eyUbTaYknQ=";
  };

  cargoHash = "sha256-/hbRzl8dh6r1mRbW1RZ2idhOJDP7HJQX6R7LpSn1xIw=";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Practice your flashcards like in Quizlet, but for the TUI";
    homepage = "https://github.com/dtomvan/rusty-words";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "rwds-cli";
  };
}
