{
  lib,
  fetchFromGitHub,
  gitMinimal,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clickup-cli";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "nicholasbester";
    repo = "clickup-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ITjn9/tltNgFRgjrREHLgC/guMhUuELeIjNrZjf9nZM=";
  };

  cargoHash = "sha256-dfGAIb21UpCD8bS7ftAd32jmDKRyFd8B5Lw5IBhG9CM=";

  nativeCheckInputs = [ gitMinimal ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "CLI for the ClickUp API, optimized for AI agents";
    homepage = "https://clickup-cli.com/";
    changelog = "https://github.com/nicholasbester/clickup-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ iamanaws ];
    mainProgram = "clickup-cli";
  };
})
