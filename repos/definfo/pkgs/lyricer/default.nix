{
  source,
  lib,
  rustPlatform,
  dbus,
  pkg-config,
}:

rustPlatform.buildRustPackage {
  inherit (source) pname src version;

  cargoLock = source.cargoLock."Cargo.lock";

  buildInputs = [ dbus ];

  nativeBuildInputs = [ pkg-config ];

  # doCheck = false;

  cargoTestFlags = [ "--future-incompat-report" ];

  meta = {
    description = "An addon for waybar to display lyrics";
    homepage = "https://github.com/moelife-coder/lyricer";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
}
