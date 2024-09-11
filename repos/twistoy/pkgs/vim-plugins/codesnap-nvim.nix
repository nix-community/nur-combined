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
  version = "1.6.0";
  codesnap-nvim-src = fetchFromGitHub {
    owner = "mistricky";
    repo = "codesnap.nvim";
    rev = "v${version}";
    sha256 = "sha256-3z0poNmS6LOS7/qGTBhvz1Q9WpYC7Wu4rNvHsUXB5ZY=";
  };
  codesnap-nvim-bin = rustPlatform.buildRustPackage {
    pname = "codesnap-nvim";
    inherit version;
    src = "${codesnap-nvim-src}/generator";
    cargoSha256 = "sha256-GudDSrFvzGkhlqOgv1pFcdv4CT2KwqRwJPGhXQzcPuU=";

    LIBCLANG_PATH = "${llvmPackages_17.libclang.lib}/lib";

    doCheck = false;

    prePatch = ''
      mkdir -p .cargo/

      echo '[target.x86_64-apple-darwin]' > .cargo/config.toml
      echo 'rustflags = [' >> .cargo/config.toml
      echo '  "-C", "link-arg=-undefined",' >> .cargo/config.toml
      echo '  "-C", "link-arg=dynamic_lookup",' >> .cargo/config.toml
      echo ']' >> .cargo/config.toml

      echo '[target.aarch64-apple-darwin]' >> .cargo/config.toml
      echo 'rustflags = [' >> .cargo/config.toml
      echo '  "-C", "link-arg=-undefined",' >> .cargo/config.toml
      echo '  "-C", "link-arg=dynamic_lookup",' >> .cargo/config.toml
      echo ']' >> .cargo/config.toml
    '';

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
