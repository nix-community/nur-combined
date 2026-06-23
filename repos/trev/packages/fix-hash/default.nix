{
  buildRustPackage ? rustPlatform.buildRustPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

buildRustPackage (finalAttrs: {
  pname = "fix-hash";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "nix-fix-hash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ApmrZyTTwoOPhYbDfH4JxnQKyhnHVtU+b/HfasCEf6s=";
  };

  cargoHash = "sha256-9yVKJeo2uDA7ej0v8Q/IKykibbOBRbzSguC/ygRs24k=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    mainProgram = "fix-hash";
    description = "Nix hash fixer";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    homepage = "https://github.com/spotdemo4/nix-fix-hash";
    changelog = "https://github.com/spotdemo4/nix-fix-hash/releases/tag/v${finalAttrs.version}";
  };
})
