{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "adsb_deku";
  version = "2023.11.22";

  src = fetchFromGitHub {
    owner = "rsadsb";
    repo = "adsb_deku";
    rev = "v${version}";
    hash = "sha256-vreda3+c0HS0+YaQZrJRBdbtQgKxw+NgkSMkDqhc+AM=";
  };

  cargoHash = "sha256-0ur+GNJna56eM99nwJHJJlAaP60lgXSTBFHZ9NHIau8=";

  meta = {
    description = "Rust ADS-B decoder + tui radar application";
    inherit (src.meta) homepage;
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
