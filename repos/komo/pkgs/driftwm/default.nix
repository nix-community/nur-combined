{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  seatd,
  mesa,
  libdisplay-info,
  libxkbcommon,
  libinput,
  libgbm,
  wayland,
  wayland-scanner,
}:
rustPlatform.buildRustPackage {
  pname = "driftwm";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "malbiruk";
    repo = "driftwm";
    tag = "v0.19.0";
    hash = "sha256-c/FGLGvP/7M+n41j85IA5OzqKBzzQ532eT7r61HCJJs=";
  };

  cargoHash = "sha256-rtSccFKbikMyeP1lT3Z1921/aKkws27apps2nZ7r6tE=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    seatd
    mesa
    libdisplay-info
    libxkbcommon
    libinput
    libgbm
    wayland
    wayland-scanner
  ];

  doCheck = false;

  passthru.update-script = nix-update-script { };
}
