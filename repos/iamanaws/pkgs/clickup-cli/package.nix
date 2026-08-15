{
  lib,
  fetchFromGitHub,
  gitMinimal,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clickup-cli";
  version = "0.15.5";

  src = fetchFromGitHub {
    owner = "nicholasbester";
    repo = "clickup-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yPEp8e/7dCnMlac1InhWJMzIJnMwcU3/Uds0lgOJrf0=";
  };

  cargoHash = "sha256-KECWIkMumpKviSJnUm0emOjdGYCOqQYWyJHzZHO5gWg=";

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
