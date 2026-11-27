{
  lib,
  fetchFromGitHub,
  git,
  nixVersions,
  rustPlatform,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "flake-show-ng";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "nix-config";
    repo = "flake-show-ng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+6FZJrhbwNWkp1fV+7VBNe9gwaYtJhBQyxb75wcqwr4=";
  };

  cargoHash = "sha256-1unXKkwQjFdZkMs62jxLyzVplbS1DB2RZurEe+iXH84=";

  doCheck = true;

  nativeCheckInputs = [
    git
    nixVersions.nix_2_34
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    export NIX_CONFIG="extra-experimental-features = nix-command flakes"
  '';

  meta = {
    description = "Show the complete tree of a flake's outputs";
    homepage = "https://github.com/nix-config/flake-show-ng";
    changelog = "https://github.com/nix-config/flake-show-ng/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ knightfemale ];
    mainProgram = "fsn";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
