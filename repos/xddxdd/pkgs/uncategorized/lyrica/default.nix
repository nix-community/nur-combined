{
  sources,
  lib,
  rustPlatform,
  pkg-config,
  dbus,
  openssl,
}:
rustPlatform.buildRustPackage {
  inherit (sources.lyrica) pname version src;

  cargoHash = "sha256-lXKnkcGX0aXv4mPKO/2xyXZSMKzr5CHADT9lg1qLVwM=";
  useFetchCargoVendor = true;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    openssl
  ];

  meta = {
    mainProgram = "lyrica";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Linux desktop lyrics widget focused on simplicity and integration";
    homepage = "https://github.com/chiyuki0325/lyrica";
    # Upsteam did not specify license
    license = lib.licenses.unfreeRedistributable;
  };
}
