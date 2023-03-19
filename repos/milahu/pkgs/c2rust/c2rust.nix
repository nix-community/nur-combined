/*
nix-build -E 'with import <nixpkgs> {}; callPackage ./c2rust.nix {}'
*/

{ lib, pkgs, fetchFromGitHub, callPackage, makeRustPlatform }:

let
  rustPlatform = mkRustPlatform {
    # https://github.com/immunant/c2rust/blob/master/rust-toolchain
    date = "2021-11-22";
    channel = "nightly";
  };

  mkRustPlatform = { date, channel }:
    let
      mozillaOverlay = fetchFromGitHub {
        owner = "mozilla";
        repo = "nixpkgs-mozilla";
        rev = "15b7a05f20aab51c4ffbefddb1b448e862dccb7d";
        sha256 = "sha256-YeN4bpPvHkVOpQzb8APTAfE7/R+MFMwJUMkqmfvytSk=";
      };
      mozilla = callPackage "${mozillaOverlay.out}/package-set.nix" {};
      rustSpecific = (mozilla.rustChannelOf { inherit date channel; }).rust;
    in
    makeRustPlatform {
      cargo = rustSpecific;
      rustc = rustSpecific;
    };
in

rustPlatform.buildRustPackage rec {
  pname = "c2rust";
  version = "unstable-2022-04-20";
  src =
    #if true then ./src/c2rust else
    fetchFromGitHub {
      owner = "immunant";
      repo = "c2rust";
      #rev = "39be293c50235b169a76e38203865c4e60378235";
      #sha256 = "sha256-o37P9lZw2XOBGhTIetkmQepr7rFCfXYetweYnejz0pM=";
      rev = "80285702e0c1bf69434eebe088315cba4f6d3430";
      sha256 = "sha256-6m7UGqO2pRtTaD4ZvcWypmoIZqH6+RyuImemby3d6Zc=";
    };
  buildType = "debug"; # build faster
  RUST_BACKTRACE = 1; # debug
  LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
  LIBCXX_INCLUDE_DIR = "${pkgs.libcxx.dev}/include";
  GLIBC_INCLUDE_DIR = "${pkgs.glibc.dev}/include";
  LLVM_CONFIG_PATH = "${pkgs.llvm.dev}/bin/llvm-config";
  LLVM_INCLUDE_DIR = "${pkgs.llvm.dev}/include"; # /nix/store/w8p79yfq5059141frg9p4z17nr6s999w-llvm-11.1.0-dev/include
  LLVM_LIB_DIR = "${pkgs.llvm.lib}/lib";
  LIBC_INCLUDE_DIR = "${pkgs.libclang.lib}/lib/clang/${pkgs.libclang.version}/include";
  /*
      Compiling c2rust-ast-exporter v0.15.0 (/build/c2rust/c2rust-ast-exporter)
    error: failed to run custom build command for `c2rust-ast-exporter v0.15.0 (/build/c2rust/c2rust-ast-exporter)`

    Caused by:
      process didn't exit successfully: `/build/c2rust/target/debug/build/c2rust-ast-exporter-15a5bcc950a5a7b0/build-script-build` (exit status: 101)
      --- stdout
      running: "cmake" "/build/c2rust/c2rust-ast-exporter/src" "-DLLVM_DIR=/nix/store/sfydnaab0wxn2qm3pkaab5x1fcagzxpf-llvm-11.1.0-lib/lib/cmake/llvm" "-DClang_DIR=/nix/store/sfydnaab0wxn2qm3pkaab5x1fcagzxpf-llvm-11.1.0-lib/lib/cmake/clang" "-DCMAKE_INSTALL_PREFIX=/build/c2rust/target/x86_64-unknown-linux-gnu/debug/build/c2rust-ast-exporter-18c84a07d822aaf2/out" "-DCMAKE_C_FLAGS= -ffunction-sections -fdata-sections -fPIC -m64" "-DCMAKE_C_COMPILER=/nix/store/pja9g36cy32z3d51942jqk91a6l2d5nv-gcc-wrapper-10.3.0/bin/cc" "-DCMAKE_CXX_FLAGS= -ffunction-sections -fdata-sections -fPIC -m64" "-DCMAKE_CXX_COMPILER=/nix/store/pja9g36cy32z3d51942jqk91a6l2d5nv-gcc-wrapper-10.3.0/bin/c++" "-DCMAKE_BUILD_TYPE=Debug"
      ...
      /build/c2rust/c2rust-ast-exporter/src/AstExporter.cpp:11:10: fatal error: llvm/Support/CommandLine.h: No such file or directory
        11 | #include "llvm/Support/CommandLine.h"
           |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
      compilation terminated.
      make[3]: *** [CMakeFiles/clangAstExporter.dir/build.make:76: CMakeFiles/clangAstExporter.dir/AstExporter.cpp.o] Error 1

    llvmPackages_11.llvm.dev                         72,932 r /nix/store/4f8rd10yc4hgzpjzndp9pw7ikaaj0ijq-llvm-11.1.0-dev/include/llvm/Support/CommandLine.h

    -> LLVM_INCLUDE_DIR
  */
  nativeBuildInputs = [
    pkgs.python3 # c2rust-refactor -> python3 process_ast.py
    pkgs.pkgconfig # c2rust-bitfields-derive -> pkg-config --libs --cflags openssl
    pkgs.llvm # c2rust-ast-exporter -> llvm-config
    pkgs.llvm.dev # c2rust-ast-exporter -> #include "llvm/Support/CommandLine.h"
    pkgs.cmake # c2rust-ast-exporter
    pkgs.glibc pkgs.glibc.dev # c2rust-ast-exporter
    pkgs.tinycbor # c2rust-ast-exporter
  ];
  buildInputs = [
    pkgs.openssl
    pkgs.zlib
    pkgs.libclang.lib pkgs.libclang.dev # c2rust-ast-exporter -> #include "clang/Frontend/FrontendActions.h"
    pkgs.libcxx pkgs.libcxx.dev # c2rust-ast-exporter -> #include <algorithm>
    pkgs.tinycbor # c2rust-ast-exporter
  ];
  cargoSha256 = "sha256-y2WwB+JfdNMZR8DHVw4e8CpLhw44LaDvRxxbLkaVUqA=";
  cargoBuildFlags = [
    "--locked"
  ];
  meta = with lib; {
    description = "Migrate C code to Rust";
    homepage = "https://github.com/immunant/c2rust";
    license = licenses.bsd3;
  };
}
