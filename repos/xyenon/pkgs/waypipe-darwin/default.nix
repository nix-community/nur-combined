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
  version = "0.11.2-darwin.1-unstable-2026-10-02";

  src = fetchFromGitHub {
    owner = "J-x-Z";
    repo = "waypipe-darwin";
    rev = "ac82084a4e154742c0f2a1a0303fdb4b562826c1";
    hash = "sha256-0y5q3U55gPToG9oW/DX7H52r2geDwwiUAyF9/rvyL4o=";
  };

  cargoHash = "sha256-38C9H1NL14xuacvjlUR45EYomdUznKC5BXg1Y5RkSH4=";

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
