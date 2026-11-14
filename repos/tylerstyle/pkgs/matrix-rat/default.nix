{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  perl,
  aws-lc,
  sqlite,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "matrix-rat";
  version = "0.1.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tylerstyle";
    repo = "matrix-rat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QodjqWeHtE3Dyn8stSMWfDzP05bA15vKF9tGK31sC3A=";
  };

  cargoHash = "sha256-s6pix/tCe6ty30Le6UdUaIUw9NlHzX9W0dapE/NhKfE=";

  nativeBuildInputs = [
    pkg-config
    cmake
    perl
  ];

  # nixpkgs tells the -sys crates to link the system libraries instead of building their
  # bundled copies
  buildInputs = [
    aws-lc
    sqlite
    zstd
  ];

  # The test suite runs in the project's own CI script; skipping it here halves the build
  doCheck = false;

  meta = {
    description = "Mouse-friendly, themeable Matrix client for the terminal";
    homepage = "https://github.com/tylerstyle/matrix-rat";
    changelog = "https://github.com/tylerstyle/matrix-rat/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ] ++ lib.optionals (lib.maintainers ? tylerstyle) [ lib.maintainers.tylerstyle ];
    mainProgram = "matrix-rat";
    platforms = lib.platforms.linux;
    # matrix-sdk 0.19 needs Rust 1.96 (rust-version in Cargo.toml); nixos-26.05 ships 1.95
    broken = lib.versionOlder rustPlatform.rust.rustc.version "1.96";
  };
})
