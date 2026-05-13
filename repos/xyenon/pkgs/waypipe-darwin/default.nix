{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  rust-bindgen,
  lz4,
  zstd,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "waypipe-darwin";
  version = "0-unstable-2025-12-15";

  src = fetchFromGitHub {
    owner = "J-x-Z";
    repo = "waypipe-darwin";
    rev = "345181a81ce5b886316cfcaeed77d6dff56a463b";
    hash = "sha256-XWzrOqXxUdxJvzUXtPVzbp2tpeKrCL+/pzlomN+438k=";
  };

  cargoHash = "sha256-gsKxdvseabVWq9SpdsxRtb4LQmMOw1RxpGLpAUvjE6s=";

  nativeBuildInputs = [
    pkg-config
    rust-bindgen
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    lz4
    zstd
  ];

  buildNoDefaultFeatures = true;
  buildFeatures = [
    "lz4"
    "zstd"
  ];

  # Darwin test builds currently fail because a test helper calls nix::unistd::pipe2,
  # which is not available on Darwin. The release binary builds successfully.
  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Proxy for Wayland clients optimized for macOS/Darwin";
    homepage = "https://github.com/J-x-Z/waypipe-darwin";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "waypipe";
    platforms = lib.platforms.darwin;
  };
}
