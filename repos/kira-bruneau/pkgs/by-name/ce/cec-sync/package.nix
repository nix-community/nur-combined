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
  version = "0-unstable-2025-04-30";

  src = fetchFromGitLab {
    owner = "kira-bruneau";
    repo = "cec-sync";
    rev = "92836390f800b6bdf2f92d0d66d3648922c573dc";
    hash = "sha256-wrb9QHkZ1XnzqaRiqY7eVX9KMaRwlKql+bbJkGYlRiQ=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-pq0tD6qAEYMXboaA9kwCJm3s42IAnKZcBbF0bfaoyw4=";

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
