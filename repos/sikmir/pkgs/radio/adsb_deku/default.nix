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
    tag = "v${version}";
    hash = "sha256-+WUG/CQ/j3muYow2FMFNUgWWhOCPZc0k+okoF1p1L5Y=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-E9WV4W2ycr4/EJDlvnLyyYOCOAgK26Kzmt48NUf9qJY=";

  meta = {
    description = "Rust ADS-B decoder + tui radar application";
    homepage = "https://github.com/rsadsb/adsb_deku";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
