{
  fetchFromGitHub,
  rustPlatform,
  lib,
  pkg-config,
  openssl,
  sqlite,
}:
rustPlatform.buildRustPackage rec {
  pname = "toutui";
  version = "0.2.0-beta";

  src = fetchFromGitHub {
    owner = "AlbanDAVID";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-U6odmgUWK8d0F6RnQHIj7OlkN6a7MPEwy5rbSbYajbk=";
  };

  useFetchCargoVendor = true;

  cargoHash = "sha256-RI5fMI+wyMa2bkQSXPsccZqphgczA/OgPq38OZT6I5M=";

  nativeBuildInputs = [
    pkg-config
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
