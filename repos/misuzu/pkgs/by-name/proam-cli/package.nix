{
  lib,
  fetchFromGitHub,
  rustPlatform,
  dbus,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "proam-cli";
  version = "unstable-2024-06-08";

  src = fetchFromGitHub {
    owner = "ilya-zlobintsev";
    repo = pname;
    rev = "7d1c15bbaa0dab8783dbbfdf3ff5ae7ba60cd63a";
    hash = "sha256-gE2dew7rTnRsw3RF74FzshZXURmfDjCo9QOaetCEKKY=";
  };

  cargoHash = "sha256-pB9AXFme2XdFv6Cp4N4+IPYNCWCNGVgYs7B1rLio50s=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dbus ];

  meta = {
    description = "CLI and Prometheus exporter for Ugreen PowerRoam portable power stations";
    homepage = "https://github.com/ilya-zlobintsev/proam-cli";
    license = lib.licenses.gpl3Only;
    mainProgram = "proam-cli";
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.linux;
  };
}
