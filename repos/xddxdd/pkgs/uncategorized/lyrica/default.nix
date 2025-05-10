{
  sources,
  lib,
  rustPlatform,
  pkg-config,
  dbus,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  inherit (sources.lyrica) pname version src;

  cargoHash = "sha256-P2lLOstdeXcnvKVqFOv+Ufd/0D8sjy7Wu4rxFEG2cms=";
  useFetchCargoVendor = true;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    openssl
  ];

  meta = {
    changelog = "https://github.com/chiyuki0325/lyrica/releases/tag/v${version}";
    mainProgram = "lyrica";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Linux desktop lyrics widget focused on simplicity and integration";
    homepage = "https://github.com/chiyuki0325/lyrica";
    # Upsteam did not specify license
    license = lib.licenses.unfreeRedistributable;
  };
}
