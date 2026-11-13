{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  perl,
  aws-lc,
  sqlite,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "matrix-rat";
  version = "0.1.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tylerstyle";
    repo = "matrix-rat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-w23FYUEQt5pcrJIRIOrHHwAG20fZatV1gGh/9Y19T6E=";
  };

  cargoHash = "sha256-GvBENARy8PAzbVqLywWBQO1nvUcWei/3S6ooOGuuQMg=";

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
