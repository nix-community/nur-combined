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
  version = "0-unstable-2024-12-05";

  src = fetchFromGitLab {
    owner = "kira-bruneau";
    repo = "cec-sync";
    rev = "708f5ba301b7d9d2705928979c76b96bba1e5658";
    hash = "sha256-ZUODCTZZXFQmHhzmY3KYPbLskQHuCgdhKSYwCiJ749U=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "cec-rs-7.1.2-alpha.0" = "sha256-6KkTnIjUOQg+rFibZjV7gm5YlHKHp7thKUg9X55j330=";
    };
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
