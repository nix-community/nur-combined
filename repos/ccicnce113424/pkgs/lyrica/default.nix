{
  sources,
  lib,
  rustPlatform,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage {
  inherit (sources) pname src;
  cargoLock = sources.cargoLock."Cargo.lock";
  inherit ((lib.importTOML sources.extract."Cargo.toml").package) version;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  metadata = sources.extract."frontend/kde/metadata.json";

  meta = {
    mainProgram = "lyrica";
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    description = "KDE Plasma lyrics widget focused on simplicity and integration";
    homepage = "https://github.com/chiyuki0325/lyrica";
    license = lib.licenses.mit;
  };
}
