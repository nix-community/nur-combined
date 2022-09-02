{ lib, stdenv, rustPlatform, fetchFromGitHub, pkg-config, sqlite }:

rustPlatform.buildRustPackage rec {
  pname = "mbutiles";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "amarant";
    repo = "mbutiles";
    rev = version;
    hash = "sha256-XVMmTqZsfIkCmZAdGi70HWiV10iawUpN3XbH93VEh7I=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-fOCOtB/orCAKQROMBCecGBxArMafkTp/dby3O4GgCMg=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ sqlite ];

  meta = with lib; {
    description = "mbtiles utility in Rust, generate MBTiles from tiles directories and extract tiles from MBTiles file";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
