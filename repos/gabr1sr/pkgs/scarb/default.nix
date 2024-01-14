{ lib, fetchurl, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "scarb";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "software-mansion";
    repo = pname;
    rev = "cba988e685f2f9b07a8ea0b5f056009f91c6c9ed";
    sha256 = "1w6a74r2awqyzl9bqylbgzrn0fy1b6wwp36xgrlr7bx76ky4ab0h";
  };

  doCheck = false;

  CAIRO_ARCHIVE = fetchurl {
    url = "https://github.com/starkware-libs/cairo/archive/refs/tags/v2.4.0.zip";
    sha256 = "0wckm1xdih8xf4znab4mg88la747skh500s5lsiybmaa01yckxg9";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  meta = {
    description = "The Cairo package manager";
    homepage = "https://github.com/software-mansion/scarb";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.mit;
  };
}
