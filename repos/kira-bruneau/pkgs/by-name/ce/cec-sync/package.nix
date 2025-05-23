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

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cec-sync";
  version = "0-unstable-2025-05-21";

  src = fetchFromGitLab {
    owner = "kira-bruneau";
    repo = "cec-sync";
    rev = "1d2daf90d2f51c7d054e4f4a86c51ad34825fe1b";
    hash = "sha256-FlNnCdIuLz9S9QLwMXZP58LLHjUvfHeezc+dqnLfvo8=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-nn/4oz+x3RVaO7AYE3gHSR0YmuAGIpEgTdareqvVYtc=";

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
})
