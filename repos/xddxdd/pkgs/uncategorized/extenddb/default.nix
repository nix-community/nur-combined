{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "extenddb";
  version = "0.1.8";
  src = fetchFromGitHub {
    owner = "ExtendDB";
    repo = "extenddb";
    tag = "v0.1.8";
    hash = "sha256-qQqdvwht8dDtrYSh4U6/Gi+zt7JpuhHxDaaS+D4V90U=";
  };
  cargoHash = "sha256-VlGMvtRhz8mluNHwBkEHVfpsly9mWZ7HPzLLb6qWTcs=";

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
