{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "adsb_deku";
  version = "2024.09.02";

  src = fetchFromGitHub {
    owner = "rsadsb";
    repo = "adsb_deku";
    rev = "v${version}";
    hash = "sha256-+WUG/CQ/j3muYow2FMFNUgWWhOCPZc0k+okoF1p1L5Y=";
  };

  cargoHash = "sha256-uiv8XdI/PkeeqlTX3pMCvSAgxTpnZlYExY1MPcNS0S8=";

  meta = {
    description = "Rust ADS-B decoder + tui radar application";
    homepage = "https://github.com/rsadsb/adsb_deku";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
