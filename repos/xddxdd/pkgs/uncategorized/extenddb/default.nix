{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "extenddb";
  version = "0.1.10";
  src = fetchFromGitHub {
    owner = "ExtendDB";
    repo = "extenddb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NzHgwvZJBbJjG385yHsK2b0ZrlGEx7GULqfs1m4sEEo=";
  };
  cargoHash = "sha256-6vobiyz+TViWTHdkKd+qm9fK+3RIHXu6DFpYrJOWnQY=";

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/ExtendDB/extenddb/releases/tag/v${finalAttrs.version}";
    homepage = "https://github.com/ExtendDB/extenddb";
    description = "DynamoDB-compatible API adapter backed by PostgreSQL";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "extenddb";
  };
})
