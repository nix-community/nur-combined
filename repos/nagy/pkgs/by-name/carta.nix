{
  lib,
  rustPlatform,
  fetchCrate,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "carta";
  version = "0.0.11";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-DDWxRUgTV8rs8CrFqBPV5cph9X7OQfLBuMKZHgaEWwk=";
  };

  cargoHash = "sha256-gs64SnajbBhILoEzGwpmPwA/S+tAT50yxa2ffYhnYK4=";

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Document converter: parse a source format and render it to a target format";
    homepage = "https://github.com/mfkrause/carta";
    changelog = "https://github.com/mfkrause/carta/releases";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "carta";
  };
})
