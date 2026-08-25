{
  lib,
  pkgs,
  stdenv,
  rustPlatform,
  pkg-config,
  makeWrapper,
  callPackage,
  apple-sdk_14,
  cargo-kani,
}:

let
  linuxGraphics = lib.optionals stdenv.hostPlatform.isLinux (
    with pkgs;
    [
      udev
      alsa-lib
      vulkan-loader
      libx11
      libxcursor
      libxi
      libxrandr
      wayland
      libxkbcommon
      mesa
    ]
  );
in
rustPlatform.buildRustPackage {
  pname = "hanga-kani";
  version = "0.1.0";

  src = ../hanga;

  cargoLock = {
    lockFile = ../hanga/Cargo.lock;
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    makeWrapper
    cargo-kani
  ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isDarwin [
      apple-sdk_14
    ]
    ++ linuxGraphics;

  env = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    LD_LIBRARY_PATH = lib.makeLibraryPath linuxGraphics;
  };

  postPatch = ''
    # Remove rust-version from vendored crates so cargo-kani doesn't abort
    chmod -R +w ../cargo-vendor-dir
    find ../cargo-vendor-dir -name Cargo.toml -exec sed -i '/rust-version/d' {} + || true

    # Fix compilation errors for crates using newly stabilized features on Kani's older compiler
    find ../cargo-vendor-dir -name 'lib.rs' -exec sed -i '1i #![feature(alloc_layout_extra, array_windows, cfg_select)]' {} + || true
  '';

  # Do not run standard cargo build
  buildPhase = ''
    echo "Skipping build phase for cargo-kani packaging"
  '';

  # Run cargo kani during the check phase
  checkPhase = ''
    export HOME=$TMPDIR/home
    mkdir -p $HOME
    export CARGO_IGNORE_RUST_VERSION=1

    # Run tests on specific targets to avoid evaluating unreachable things if possible, but we run on all by default
    cargo kani --default-unwind 3
  '';

  installPhase = ''
    mkdir -p $out
    echo "Kani checks passed" > $out/status
  '';

  meta = {
    description = "Hanga Kani proofs check";
    license = lib.licenses.mit;
  };
}
