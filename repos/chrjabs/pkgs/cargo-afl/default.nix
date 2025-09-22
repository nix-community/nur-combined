# NOTE:to use this package, override the `rustPlatform` input with the rust
# version you want to use this with
{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  aflplusplus,
  makeWrapper,
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-afl";
  version = "0.15.22";

  src = fetchFromGitHub {
    owner = "rust-fuzz";
    repo = "afl.rs";
    rev = "b3afda8d82ca9d51fb6a3dd6c6a2202880c8dad0";
    hash = "sha256-Ux/imznWCxV/8w7I/Bk/hMF1OwewPbD9hg1NWvXIt6s=";
  };

  cargoHash = "sha256-tTKQ0lX7tOvU/P97NJ36Eu7hVqMc7mW5Fp2Hx+SuxCM=";

  doCheck = false;

  buildInputs = [
    aflplusplus
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postBuild = ''
    ar r libafl-llvm-rt.a ${aflplusplus}/lib/afl/afl-compiler-rt.o
  '';

  postInstall = ''
    RUSTC_VERSION=$(rustc --version | cut -d' ' -f2)
    RUSTC_HASH=$(rustc --version | cut -d'(' -f2 | cut -b1-7)
    DATA_DIR=$out/share/afl.rs/rustc-$RUSTC_VERSION-$RUSTC_HASH/afl.rs-${version}
    mkdir -p $DATA_DIR/afl/
    mkdir -p $DATA_DIR/afl-llvm/
    ln -s ${aflplusplus}/bin $DATA_DIR/afl/
    cp ${aflplusplus}/lib/afl/afl-compiler-rt.o $DATA_DIR/afl-llvm/libafl-llvm-rt.o
    mv libafl-llvm-rt.a $DATA_DIR/afl-llvm/
  '';

  postFixup = ''
    wrapProgram $out/bin/cargo-afl --set XDG_DATA_HOME $out/share/
  '';

  meta = with lib; {
    description = "Fuzzing Rust code with american-fuzzy-lop";
    mainProgram = "cargo-afl";
    homepage = "https://github.com/rust-fuzz/afl.rs";
    license = with licenses; [
      asl20
    ];
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
  };
}
