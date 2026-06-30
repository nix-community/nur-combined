{
  sources,
  lib,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources.extenddb) pname version src;

  cargoHash = "sha256-QRLKwuTSKnOmTXmP00y3rmxKqqT80UIUNRXCDSDjK24=";

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'version = "0.1.0"' 'version = "${finalAttrs.version}"'
  '';

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
