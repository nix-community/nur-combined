{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rwds-cli";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "dtomvan";
    repo = "rusty-words";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AbZOSUka5z1mCA/RecW0ghmmb5O+C1LpFGyBWVpVSz4=";
  };

  cargoHash = "sha256-/hbRzl8dh6r1mRbW1RZ2idhOJDP7HJQX6R7LpSn1xIw=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Practice your flashcards like in Quizlet, but for the TUI";
    homepage = "https://github.com/dtomvan/rusty-words";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "rwds-cli";
  };
})
