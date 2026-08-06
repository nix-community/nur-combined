{
  lib,
  fetchFromGitHub,
  gitMinimal,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clickup-cli";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "nicholasbester";
    repo = "clickup-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8ZchwqqBQcKjlk2ffA6b5Ue+x9fv4DLUdQuLCGw/N7A=";
  };

  cargoHash = "sha256-+2oVoeCUkH0Y/wnWO8wMdVLJ3HEecTmKRbywNHGwdec=";

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
