{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "osmptparser";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "cualbondi";
    repo = "osmptparser";
    rev = "v${version}";
    hash = "sha256-+u1UP+hFI8fi+NAzQ4pIObo+ZCBBaEoIkUNvHPO7jSQ=";
  };

  cargoHash = "sha256-Hl0K3E6mIbdl4h6Q9pZp71OVdgsuc2jKQWvDaNKM4FA=";

  doCheck = false;

  meta = {
    description = "Open Street Map Public Transport Parser";
    homepage = "https://github.com/cualbondi/osmptparser";
    license = lib.licenses.agpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "osmptparser";
  };
}
