{
  sources,
  lib,
  rustPlatform,
  pkg-config,
  dbus,
  openssl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources.lyrica) pname version src;

  cargoHash = "sha256-wklBPXAiR/J9wY51czzyGh5ge9yG3hZP0jG3oPmdAXc=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    openssl
  ];

  meta = {
    changelog = "https://github.com/chiyuki0325/lyrica/releases/tag/v${finalAttrs.version}";
    mainProgram = "lyrica";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Linux desktop lyrics widget focused on simplicity and integration";
    homepage = "https://github.com/chiyuki0325/lyrica";
    # Upstream did not specify license
    license = lib.licenses.unfreeRedistributable;
  };
})
