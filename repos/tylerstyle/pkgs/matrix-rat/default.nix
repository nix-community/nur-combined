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
  version = "0.2.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tylerstyle";
    repo = "matrix-rat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CoRPeBN3+AHBuzjY6osvXU2l6tq2j0Sgjg+cyss65QI=";
  };

  cargoHash = "sha256-V7ggbj2ZVSc/i8kRGV6W9A6eRrnTyzfqMm2JnAHBT+U=";

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
