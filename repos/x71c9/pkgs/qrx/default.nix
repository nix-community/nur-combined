{ lib, rustPlatform, fetchFromGitHub, xorg }:

rustPlatform.buildRustPackage rec {
  pname = "qrx";
  version = "0.4.0"; # without "v"

  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "qrx";
    rev = "v${version}";
    hash = "sha256-WcqHb2YEn4aLdHmGDRd+ffkzb7ZO8PL3vIxhEnWcFzY=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  buildInputs = [ xorg.libxcb ];

  doCheck = false;

  mainProgram = "qrx";

  meta = with lib; {
    description = "CLI tool to capture a screen region, decode any QR code found, and copy the result to clipboard.";
    homepage = "https://github.com/x71c9/qrx";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
