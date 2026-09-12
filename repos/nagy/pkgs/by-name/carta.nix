{
  lib,
  rustPlatform,
  fetchCrate,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "carta";
  version = "0.0.10";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-z2H4sZnnURacyq15rbXWks9NvHz+peCF8/fuKuuS8dM=";
  };

  cargoHash = "sha256-VIu3jMAgx9twWd+gHOwnAcytGkrcpYUv0ZoXZoOFU0o=";

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
