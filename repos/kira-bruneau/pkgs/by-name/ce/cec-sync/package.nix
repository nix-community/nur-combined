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
  version = "0-unstable-2025-07-16";

  src = fetchFromGitLab {
    owner = "kira-bruneau";
    repo = "cec-sync";
    rev = "79c31098fcddf6dee0a0143ba6093f7729206038";
    hash = "sha256-Z3mM5ayB0c9Rr6zcInWTNgnR97P7TFaiXm+/QtazPeg=";
  };

  cargoHash = "sha256-itOHCUdQNPE6T84LXo0yBIxdN86FbrIibyvfm17Ebzw=";

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

  meta = {
    description = "Service for integrating Linux devices into a home theatre system over HDMI-CEC";
    homepage = "https://gitlab.com/kira-bruneau/cec-sync";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ kira-bruneau ];
    platforms = lib.platforms.linux;
    mainProgram = "cec-sync";
  };
})
