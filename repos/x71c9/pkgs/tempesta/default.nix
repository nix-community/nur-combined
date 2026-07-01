{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "tempesta";
  version = "0.1.40"; # without "v"

  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "tempesta";
    rev = "v${version}";
    hash = "sha256-efm05oESQ3Oli8cjT2IBiKRVNCqlbVgGNH14i8zgqe4=";
  };

  cargoLock.lockFile = ./Cargo.lock;


  doCheck = false;

  mainProgram = "tempesta";

  meta = with lib; {
    description = "The fastest and lightest bookmark manager CLI written in Rust";
    homepage = "https://github.com/x71c9/tempesta";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
