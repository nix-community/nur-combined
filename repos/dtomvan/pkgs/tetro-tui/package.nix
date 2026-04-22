{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tetro-tui";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "Strophox";
    repo = "tetro-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nT3NLrbjMZVAb7K75QZkLbZDDi1jKLNsoDnb3ENELrk=";
  };

  cargoHash = "sha256-hOpjoKq3QKffa4qTlN1tvLW739UggRWAGe464UqkpiM=";

  meta = {
    description = "Terminal-based tetris game in crossterm";
    homepage = "https://github.com/Strophox/tetro-tui";
    changelog = "https://github.com/Strophox/tetro-tui/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "tetro-tui";
  };
})
