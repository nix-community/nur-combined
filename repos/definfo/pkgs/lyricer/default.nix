{
  lib,
  rustPlatform,
  fetchFromGitHub,
  dbus,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "lyricer";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "moelife-coder";
    repo = pname;
    rev = "f0f8d99b23102755ce7c70830127b23cfde96f3e";
    sha256 = "sha256-sviP/0b77uu+C9ihfHnYNwIehStBp5m2WIDW9sqVq1k=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

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
