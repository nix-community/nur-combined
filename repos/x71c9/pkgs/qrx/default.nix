{ lib, rustPlatform, fetchFromGitHub, libxcb }:

rustPlatform.buildRustPackage rec {
  pname = "qrx";
  version = "0.5.0"; # without "v"

  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "qrx";
    rev = "v${version}";
    hash = "sha256-QIdBr/AnDHDjrsYc0OOZn5A2HiGyMGBIndMh0AHEyk4=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  buildInputs = [ libxcb ];

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
