{
  fetchFromGitHub,
  rustPlatform,
  lib,
  pkg-config,
  openssl,
  sqlite,
  perl,
}:
rustPlatform.buildRustPackage rec {
  pname = "toutui";
  version = "0.4.2-beta";

  src = fetchFromGitHub {
    owner = "AlbanDAVID";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-0BayJTr9eomFTkvRdGKp/EZ6mhovDGfUlqOuEBbufyM=";
  };

  cargoHash = "sha256-fb6lYpPEt9Mzu52V/hZ3EL00ldJUNpZBLoZhB4BX4K8=";

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  buildInputs = [
    openssl
    sqlite
  ];

  meta = {
    description = "Toutui is a TUI Audiobookshelf Client for Linux";
    homepage = "https://github.com/AlbanDAVID/Toutui";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [renesat];
  };
}
