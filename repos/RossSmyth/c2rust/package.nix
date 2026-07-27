{
  lib,
  # Requires rust-overlay for the pinned nightly
  # Specifically it requires an old snapshop.
  rust-bin,
  makeRustPlatform,
  rustc,
  clangStdenv,
  fetchFromGitHub,
  # binaries
  llvmPackages,
  cmake,
  pkg-config,
  # libraries
  tinycbor,
}:
let
  # Something changed in nixpkgs since this snapshot,
  # so we need to stuff some additional attributes in it.
  toolchain =
    rust-bin.nightly."2022-08-08".minimal.override
      or (throw "Requires the snapshot/2024-08-01 tag of rust-overlay")
      {
        extensions = [
          "rustc-dev"
          "rust-src"
        ];
      }
    // {
      inherit (rustc) targetPlatforms badTargetPlatforms;
    };

  rustPlatform = makeRustPlatform {
    stdenv = clangStdenv;
    rustc = toolchain;
    cargo = toolchain;
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  strictDeps = true;
  pname = "c2rust";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "immunant";
    repo = "c2rust";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bC0FsYYhosQXPsdDrd0Xw7hUqBfdcLXsCpPI+ILCXbI=";
  };

  patches = [
    ./tinycbor.patch
  ];

  cargoHash = "sha256-kKy9nG4kN2NjWspwHV/d1jubH08MzzgApBrLFb3MxqI=";

  nativeBuildInputs = [
    llvmPackages.libllvm
    cmake
    pkg-config
  ];

  buildInputs = [
    tinycbor
    llvmPackages.libclang
  ];

  env = {
    CMAKE_CLANG_DIR = "${llvmPackages.libclang.dev}/lib/cmake/clang";
    LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
    RUSTFLAGS = "-L native=${tinycbor}/lib";
  };

  # FIXME: uhhhhhhhhhhhhhhhhhhhhhhhhhhhh
  doCheck = false;

  passthru.toolchain = toolchain;

  meta = {
    description = "helper for migrating C99 code to Rust";
    homepage = "https://c2rust.com/";
    changelog = "https://github.com/immunant/c2rust/releases/tag/v${finalAttrs.version}";
    downloadPage = "https://github.com/immunant/c2rust";
    mainProgram = "c2rust";
    license = with lib.licenses; [
      # c2rust
      bsd3
      # c2rust/c2rust-ast-pritner
      mit
      asl20
    ];
    maintainers = [ lib.maintainers.RossSmyth ];
  };
})
