{
  fetchFromGitHub,
  lib,
  nix-update-script,
  pkg-config,
  rustPlatform,
  udev,
}:

rustPlatform.buildRustPackage {
  pname = "gps-share";
  # require 0.3.1-unstable because 0.3.1 doesn't pass `doCheck`; tip has test fixes
  version = "0.3.1-unstable-2026-07-21";

  src = fetchFromGitHub {
    owner = "zeenix";
    repo = "gps-share";
    rev = "aa7a1bac446390eeb39f9382c724bbbb36619c40";
    hash = "sha256-tK4rt96foufY/Ai2l++zUwtCZVQOu7Ap08P3Qgk4Ta0=";
  };

  cargoHash = "sha256-t5muhj4y/Sx/G9v/PAsHmBFqjqAE6uaJd6/viSl4L/8=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    udev
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "utility to share your GPS device on local network";
    homepage = "https://github.com/zeenix/gps-share";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
