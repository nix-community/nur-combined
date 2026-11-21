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
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "nix-config";
    repo = "flake-show-ng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-e1FPmd9VJsRwePlS/9YAtIhxxpYRo7qybKgIRIMoNl8=";
  };

  cargoHash = "sha256-CjI5FxNDW9TWjTigQxtNpuoBHjdWhVB5Dm5YhHF/PFQ=";

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
