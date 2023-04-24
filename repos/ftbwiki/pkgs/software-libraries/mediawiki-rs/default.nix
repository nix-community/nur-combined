{ lib, fetchFromGitHub, rustPlatform, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "mediawiki-rs";
  version = "2021-06-05";

  src = fetchFromGitHub {
    owner = "FTB-Gamepedia";
    repo = pname;
    rev = "19a0000241d89e691fb51561ece6ad41f8d961ba";
    sha256 = "sha256-waGHh75+tOoDIXUiTOIzcH64hhLwLdhkavJCW/CL/ig=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  cargoPatches = [
    # a patch file to add/update Cargo.lock in the source code
    ./lockfile.patch
  ];

  buildInputs = [ openssl ];

  nativeBuildInputs = [ pkg-config ];


  meta = with lib; {
    description = "A library for interfacing with the MediaWiki APIs from Rust";
    homepage = "https://github.com/FTB-Gamepedia/mediawiki-rs";
    license = with licenses; [ mit asl20 ];
  };
}
