{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "extenddb";
  version = "0.1.13";
  src = fetchFromGitHub {
    owner = "ExtendDB";
    repo = "extenddb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rNJZH7gYDGaB1MkmAmfteqCKuaRtnO9Z3BfnAS9rSK0=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-uRHtU+FLwzu66VbDUIsSnx5mitfKw7VYRtUDIw3XOSk=";

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
