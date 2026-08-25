{
  lib,
  stdenv,
  pkgs,
  fetchFromGitHub,
  pkg-config,
  openssl,
  zlib,
  makeRustPlatform,
}:

let
  fenix_repo = pkgs.fetchzip {
    url = "https://github.com/nix-community/fenix/archive/main.tar.gz";
    hash = "sha256-37asD+JKFnedthzsuGP8mDgxCzjNePJVfMAVzYWIMfs=";
  };
  fenix = import fenix_repo { inherit pkgs; };
  toolchain_components = fenix.targets.x86_64-unknown-linux-gnu.toolchainOf {
    channel = "nightly";
    date = "2025-11-21";
    sha256 = "sha256-P39FCgpfDT04989+ZTNEdM/k/AE869JKSB4qjatYTSs=";
  };
  toolchain = fenix.combine [
    toolchain_components.rustc
    toolchain_components.cargo
    toolchain_components.rust-std
    toolchain_components.rustc-dev
    toolchain_components.llvm-tools-preview
    toolchain_components.rust-src
  ];

  # Kani 0.67.0
  version = "0.67.0";

  rustPlatform = makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  };
in
rustPlatform.buildRustPackage rec {
  pname = "cargo-kani";
  inherit version;

  src = fetchFromGitHub {
    owner = "model-checking";
    repo = "kani";
    rev = "kani-${version}";
    fetchSubmodules = true;
    hash = "sha256-Advfh0BWvvEbnwWvTpHzu/7MI9P0/dhzvtX9r2qnXeI=";
  };

  cargoHash = "sha256-0OsKKOJVqga/sLwzA0zNgV1bOlYObPO9LSJVLKq8mik=";

  env = {
    RUSTUP_HOME = "dummy";
    RUSTUP_TOOLCHAIN = "dummy";
  };

  cargoPatches = [
    ./cargo-lock.patch
  ];

  nativeBuildInputs = [
    pkg-config
    pkgs.cbmc
    pkgs.kissat
  ];

  buildInputs = [
    openssl
    zlib
  ];

  buildPhase = ''
    runHook preBuild
    export CARGO_OFFLINE=true
    cargo run --offline -p build-kani -- bundle
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    tar -xzf kani-0.67.0-*.tar.gz -C $out --strip-components=1

    # Remove proxy wrappers and symlink the real kani-driver
    rm -f $out/bin/cargo-kani $out/bin/kani
    ln -s $out/bin/kani-driver $out/bin/cargo-kani
    ln -s $out/bin/kani-driver $out/bin/kani
    mkdir -p $out/toolchain/bin $out/toolchain/lib
    ln -s ${toolchain}/lib/* $out/toolchain/lib/
    ln -s ${toolchain}/lib/*.so $out/lib/
    ln -s ${toolchain}/bin/cargo $out/toolchain/bin/cargo
    ln -s ${toolchain}/bin/rustc $out/toolchain/bin/rustc
    runHook postInstall
  '';

  meta = with lib; {
    description = "Kani Rust Verifier";
    homepage = "https://model-checking.github.io/kani/";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}
