{
  lib,
  fetchFromGitHub,
  rustPlatform,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "dedoc";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "toiletbril";
    repo = "dedoc";
    rev = version;
    hash = "sha256-BZW1qz0oFLd3oZoefMLrGEgLx0W+YUxHkbQC7kuRngo=";
  };

  cargoHash = "sha256-FcER5ryvdKL+75QXzvirkb6r1QzjmXoZYzolS0UgVfQ=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  meta = {
    description = "Terminal based viewer for DevDocs";
    homepage = "https://github.com/toiletbril/dedoc";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [renesat];
  };
}
