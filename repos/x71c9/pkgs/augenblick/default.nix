{ lib, rustPlatform, fetchFromGitHub, libxcb }:

rustPlatform.buildRustPackage rec {
  pname = "augenblick";
  version = "0.4.0"; # without "v"

  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "augenblick";
    rev = "v${version}";
    hash = "sha256-sMzsRBS/Q9IhLkKlU9swqsKALBfvu7L4Q+zTHGjoG70=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  buildInputs = [ libxcb ];

  doCheck = false;

  mainProgram = "augenblick";

  meta = with lib; {
    description = "Fullscreen eye-blink overlay for X11 and Wayland";
    homepage = "https://github.com/x71c9/augenblick";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
