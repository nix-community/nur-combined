{
  fetchFromGitHub,
  lib,
  rustPlatform,
  dbus,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "lyricer";
  version = "f0f8d99b23102755ce7c70830127b23cfde96f3e";

  src = fetchFromGitHub {
    owner = "moelife-coder";
    repo = "lyricer";
    rev = version;
    sha256 = "sha256-sviP/0b77uu+C9ihfHnYNwIehStBp5m2WIDW9sqVq1k=";
  };

  useFetchCargoVendor = true;

  cargoHash = "sha256-An0wTtIjqI3+hbYtb2bbwiMskVQVrWTUDMR3aNU+8IM=";

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
