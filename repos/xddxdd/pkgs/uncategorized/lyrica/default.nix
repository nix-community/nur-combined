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

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "netease-cloud-music-api-1.3.2" = "sha256-fVtp15P4o2eqtYvoArGoPhfX8QYJ+FRoOvB16if7KWQ=";
    };
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    openssl
  ];

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Linux desktop lyrics widget focused on simplicity and integration";
    homepage = "https://github.com/chiyuki0325/lyrica";
    # Upsteam did not specify license
    license = licenses.unfreeRedistributable;
  };
}
