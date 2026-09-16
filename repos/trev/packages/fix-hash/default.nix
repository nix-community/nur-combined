{
  buildRustPackage ? rustPlatform.buildRustPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:

buildRustPackage (finalAttrs: {
  pname = "fix-hash";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "nix-fix-hash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l3adu34mPJNk70ymC3S/7qQA3+vMMjntBlwnvgWPC7I=";
  };

  cargoHash = "sha256-JyRTnFxjN17yaSoarsP2B1q5JsCAwy8YzAIOOtTPZsc=";

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
