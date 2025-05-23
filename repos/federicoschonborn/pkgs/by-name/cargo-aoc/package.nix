{
  lib,
  rustPlatform,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-aoc";
  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "gobanos";
    repo = "cargo-aoc";
    tag = finalAttrs.version;
    hash = "sha256-k9Lm91+Bk6EC8+KfEXhSs4ki385prZ6Vbs6W+18aZSI=";
  };

  cargoHash = "sha256-1wWqIA0MtnG5nrHLpmheV1a3qDIiBPTa9HCxSPh9ftQ=";

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  # Outputs "0.3.0" for some reason...
  dontVersionCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "cargo-aoc";
    description = "Cargo Advent of Code Helper";
    homepage = "https://github.com/gobanos/cargo-aoc";
    changelog = "https://github.com/gobanos/cargo-aoc/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
