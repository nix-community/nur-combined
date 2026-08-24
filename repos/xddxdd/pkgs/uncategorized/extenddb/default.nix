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
    tag = "v0.1.7";
    hash = "sha256-hYIWVE7ouiSLxUTJ6OvJHrjPL7kpUw7JY+ItZHK/el4=";
  };
  cargoHash = "sha256-aIePKcMAgNNyhzCThnU0xVi+26lpw2e+vNmgo26mlfk=";

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
