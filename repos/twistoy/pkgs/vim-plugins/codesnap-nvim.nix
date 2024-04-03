{
  lib,
  stdenv,
  darwin,
  buildVimPlugin,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  llvmPackages_17,
  libuv,
  luajit,
  ...
}: let
  version = "1.1.4";
  codesnap-nvim-src = fetchFromGitHub {
    owner = "mistricky";
    repo = "codesnap.nvim";
    rev = "v${version}";
    sha256 = "qU0fxW0/25MBlYlzLEJFYBGu7RnO+ItqD0zhBzthYno=";
  };
  codesnap-nvim-bin = rustPlatform.buildRustPackage {
    pname = "codesnap-nvim";
    inherit version;
    src = "${codesnap-nvim-src}/generator";
    cargoSha256 = "Z9vZVq1I8ChKagBFOb7IPKPcFA5mU/YGybno+EKCoUU=";

    LIBCLANG_PATH = "${llvmPackages_17.libclang.lib}/lib";

    NIX_LDFLAGS = lib.optionalString stdenv.cc.isClang "-l${stdenv.cc.libcxx.cxxabi.libName}";
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-fno-lto";

    doCheck = false;

    nativeBuildInputs = [
      pkg-config
      llvmPackages_17.libclang
      libuv
      luajit
    ];

    buildInputs =
      [
        llvmPackages_17.libclang
        rustPlatform.bindgenHook
        libuv
        luajit
      ]
      ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk_11_0.frameworks; [
        CoreServices
        AppKit
        ApplicationServices
        CoreVideo
        Security
      ]);
  };
in
  buildVimPlugin {
    pname = "codesnap-nvim";
    inherit version;
    src = codesnap-nvim-src;
    propagatedBuildInputs = [codesnap-nvim-bin];
    preFixup = ''
      cp "${codesnap-nvim-bin}/lib/libgenerator.dylib" "$out/lua/generator.so" || true
      cp "${codesnap-nvim-bin}/lib/libgenerator.so"    "$out/lua/generator.so" || true
    '';
  }
