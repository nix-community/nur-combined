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
  version = "0-unstable-2024-11-23";

  src = fetchFromGitLab {
    owner = "kira-bruneau";
    repo = "cec-sync";
    rev = "a0d987ba1407ef935c1e8437a40a7ae395bfd3be";
    hash = "sha256-BciViSGaMb3hiOmdt+2JNgcrcZQA96yVvUDW/XZi0GI=";
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
    description = "A service for integrating Linux devices into a home theatre system over HDMI-CEC";
    homepage = "https://gitlab.com/kira-bruneau/cec-sync";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
    mainProgram = "cec-sync";
  };
}
