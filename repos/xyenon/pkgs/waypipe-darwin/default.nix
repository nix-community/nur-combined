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
  version = "0-unstable-2026-07-13";

  src = fetchFromGitHub {
    owner = "J-x-Z";
    repo = "waypipe-darwin";
    rev = "4b78e265c91d62109b17ee28ef1e0511009c1c89";
    hash = "sha256-0JCyQsee28ovmw4fkDZL7rB2w0TepbjBzBnNTMo+0gE=";
  };

  cargoHash = "sha256-IUvXHLxrhc2Au57wsE53Q+NL1cZzFcaRG3HDV8s3xWw=";

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
