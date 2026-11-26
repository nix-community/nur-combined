{
  lib,
  rustPlatform,
  fetchCrate,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "carta";
  version = "0.0.15";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-hE4dgeQoG/I44eJ0yxXs0FRUrjXaze04f/nVF9CLLuI=";
  };

  cargoHash = "sha256-3AxmqUxq+JMBcHH/N104kEXojfm6NouSTC0HQID58WM=";

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
