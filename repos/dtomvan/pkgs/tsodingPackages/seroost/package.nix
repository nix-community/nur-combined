{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cairo,
  glib,
  poppler,
}:
rustPlatform.buildRustPackage {
  pname = "seroost";
  version = "0-unstable-2023-04-03";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "seroost";
    rev = "94b6383b0e2b4f6f4777d5f969ba0dd846e797cf";
    hash = "sha256-Hlotlu5O1J4vcr5PDzm/4qwbXX5+M8JjDshI+44DM6s=";
  };

  cargoHash = "sha256-5f/Yx9JpeLTGrL2ODnFwMGYnzUJUixx0Jeqxg/7unNs=";

  doCheck = false;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    cairo
    glib
    poppler
  ];

  meta = {
    description = "Local Search Engine";
    homepage = "https://github.com/tsoding/seroost";
    license = lib.licenses.mit;
    mainProgram = "seroost";
  };
}
