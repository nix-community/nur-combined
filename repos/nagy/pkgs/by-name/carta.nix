{
  lib,
  rustPlatform,
  fetchCrate,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "carta";
  version = "0.0.13";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-kx6CmyGW8V033DxA4dOKopZ6i+LQvQcaVufVp2IvXhA=";
  };

  cargoHash = "sha256-WhOA/n8KTt8rdRCmHNcF8FkFcTUxGGseVV/WCq+8t0I=";

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

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
