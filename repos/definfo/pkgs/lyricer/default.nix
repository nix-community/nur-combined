{
  fetchFromGitHub,
  lib,
  rustPlatform,
  dbus,
  pkg-config,
}:

rustPlatform.buildRustPackage {
  pname = "lyricer";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "moelife-coder";
    repo = "lyricer";
    rev = "f0f8d99b23102755ce7c70830127b23cfde96f3e";
    sha256 = "sha256-sviP/0b77uu+C9ihfHnYNwIehStBp5m2WIDW9sqVq1k=";
  };

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
