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
      "netease-cloud-music-api-1.4.0" = "sha256-Vy0iOmH8DpaF1upYiHnHqHLhdhQjbRw94pbFdmv546A=";
    };
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    openssl
  ];

  meta = with lib; {
    mainProgram = "lyrica";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Linux desktop lyrics widget focused on simplicity and integration";
    homepage = "https://github.com/chiyuki0325/lyrica";
    # Upsteam did not specify license
    license = licenses.unfreeRedistributable;
  };
}
