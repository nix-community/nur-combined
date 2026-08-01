{
  lib,
  fetchFromGitHub,
  gitMinimal,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clickup-cli";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "nicholasbester";
    repo = "clickup-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dncIX6a4zWwmQX7X/lHUP6zJmYXt9bkkFrLVEfPZVxY=";
  };

  cargoHash = "sha256-0ImXPccH/enV+kotqccZMFJGDA+Yayjr5/t+axXFALc=";

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
