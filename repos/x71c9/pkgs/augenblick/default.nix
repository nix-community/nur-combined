{ lib, rustPlatform, fetchFromGitHub, libxcb }:

rustPlatform.buildRustPackage rec {
  pname = "augenblick";
  version = "0.5.3"; # without "v"

  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "augenblick";
    rev = "v${version}";
    hash = "sha256-rMgfWV7I/l+BEAKRb7bK7z+ZLKn0FT/OB92ME7YuDgI=";
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
