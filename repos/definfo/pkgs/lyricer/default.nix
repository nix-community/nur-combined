{
  source,
  lib,
  rustPlatform,
  dbus,
  pkg-config,
}:

rustPlatform.buildRustPackage {
  inherit (source) pname src version;

  useFetchCargoVendor = true;

  cargoHash = "sha256-r9ZiYNPQJRhHyeBNZI1VZSjFYgmZf2soAEWlAi0Iddk=";

  buildInputs = [ dbus ];

  nativeBuildInputs = [ pkg-config ];

  # doCheck = false;

  cargoTestFlags = [ "--future-incompat-report" ];

  meta = {
    description = "An addon for waybar to display lyrics";
    homepage = "https://github.com/moelife-coder/lyricer";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ definfo ];
  };
}
