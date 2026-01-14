{
  sources,
  lib,
  rustPlatform,
  pkg-config,
  openssl,
  dbus,
}:
let
  metadata = lib.importJSON sources.extract."plasmoid/metadata.json";
in
rustPlatform.buildRustPackage {
  inherit (sources) pname src;
  version = metadata.KPlugin.Version;
  cargoLock = sources.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    dbus
  ];

  metadata = sources.extract."plasmoid/metadata.json";

  meta = {
    mainProgram = "lyrica";
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    description = "KDE Plasma lyrics widget focused on simplicity and integration";
    homepage = "https://github.com/chiyuki0325/lyrica";
    changelog = "https://github.com/chiyuki0325/lyrica/releases/tag/${sources.version}";
    license = lib.licenses.mit;
  };
}
