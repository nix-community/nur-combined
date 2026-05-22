{
  sources,
  lib,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources.extenddb) pname version src;

  cargoHash = "sha256-m0sC1oK1cRaSVyZyp532PkC5/CkZN80Pk42krWDLNB0=";

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  meta = {
    changelog = "https://github.com/ExtendDB/extenddb/releases/tag/v${finalAttrs.version}";
    homepage = "https://github.com/ExtendDB/extenddb";
    description = "DynamoDB-compatible API adapter backed by PostgreSQL";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "extenddb";
  };
})
