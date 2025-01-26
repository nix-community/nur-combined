{
  lib,
  rustPlatform,
  fetchFromGitLab,
  pkg-config,
  libcec,
  udev,
  wayland,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cec-sync";
  version = "0-unstable-2025-01-25";

  src = fetchFromGitLab {
    owner = "kira-bruneau";
    repo = "cec-sync";
    rev = "88bcd13b3cf446f1d76688fb462f7a59a68556d7";
    hash = "sha256-/S3X9rWfzmve2HbqEelY+XcQwNtuBTBOedNuL0oOW/A=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libcec
    udev
    wayland
  ];

  C_INCLUDE_PATH = "${libcec}/include/libcec";

  # No tests
  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Service for integrating Linux devices into a home theatre system over HDMI-CEC";
    homepage = "https://gitlab.com/kira-bruneau/cec-sync";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
    mainProgram = "cec-sync";
  };
}
