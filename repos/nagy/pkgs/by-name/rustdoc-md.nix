{
  lib,
  rustPlatform,
  fetchCrate,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustdoc-md";
  version = "0.2.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-Gk3T3uMMN80tpSFgLfeXyarZTJI7c+iw/Jv3YLFDfYQ=";
  };

  cargoHash = "sha256-lk8nFoSqIfRnk1zFcTL6EbmTOpGExt6g0rgcYEvNL2M=";

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Convert Rust documentation JSON into clean, organized Markdown files";
    homepage = "https://github.com/tqwewe/rustdoc-md";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "rustdoc-md";
  };
})
