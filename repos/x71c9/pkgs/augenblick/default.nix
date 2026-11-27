{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "augenblick";
  version = "0.6.3"; # without "v"

  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "augenblick";
    rev = "v${version}";
    hash = "sha256-GqgXOyuXiMuB476s9/OLiG3nQClWKl7L0qQhrGEU56U=";
  };

  cargoLock.lockFile = ./Cargo.lock;


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
