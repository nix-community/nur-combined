{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "themethod3";
  version = "2024-02-24";

  src = fetchFromGitHub {
    owner = "DarkRTA";
    repo = pname;
    rev = "393e0ee31eba2d5b659429dbe53b092ff8ea717e";
    sha256 = "sha256-gdc4OGqGQRCL3JLlY6hq2RcPWvgUmdffYCdygNvUY94=";
  };

  cargoPatches = [
    ./add-Cargo.lock.patch
  ];

  cargoSha256 = "sha256-uUobNvQKDabJKyod1YThc9kGvK4cZfhIOL1uK1w0VAk=";
}
