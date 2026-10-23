{ lib, rustPlatform, fetchFromGitHub, libxcb }:

rustPlatform.buildRustPackage rec {
  pname = "augenblick";
  version = "0.5.1"; # without "v"

  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "augenblick";
    rev = "v${version}";
    hash = "sha256-NuAyga15lNswyA4WAP8HVgzv+oSsLj/c1klxzFfHbpg=";
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
