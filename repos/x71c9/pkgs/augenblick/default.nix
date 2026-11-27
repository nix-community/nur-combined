{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "augenblick";
  version = "0.6.2"; # without "v"

  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "augenblick";
    rev = "v${version}";
    hash = "sha256-1cC78xQTEFYYMN3r1jGpsuxp7D0f93P/RySHb9j9AUA=";
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
