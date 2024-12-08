{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  darwin,
  buildVimPlugin,
  ...
}: let
  version = "2024-11-2";

  src = fetchFromGitHub {
    owner = "yetone";
    repo = "avante.nvim";
    rev = "4464b7f4ae26254cd506a354284a02129941e244";
    hash = "sha256-erB/WVH+K9vNM30Bmfih7DuuLy+1Ns/begNCMUYbNEA=";
  };

  meta = with lib; {
    description = "Neovim plugin designed to emulate the behaviour of the Cursor AI IDE";
    homepage = "https://github.com/yetone/avante.nvim";
    license = licenses.asl20;
  };

  avante-nvim-lib = rustPlatform.buildRustPackage {
    pname = "avante-nvim-lib";
    inherit version src meta;
    cargoLock = {
      lockFile = ./Cargo.lock;
    };

    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs =
      [
        openssl
      ]
      ++ lib.optionals stdenv.isDarwin [
        darwin.apple_sdk.frameworks.Security
      ];

    buildFeatures = ["luajit"];

    doCheck = false;
  };
in
  buildVimPlugin {
    pname = "avante.nvim";
    inherit version src meta;

    postInstall = let
      ext = stdenv.hostPlatform.extensions.sharedLibrary;
    in ''
      mkdir -p $out/build
      ln -s ${avante-nvim-lib}/lib/libavante_repo_map${ext} $out/build/avante_repo_map${ext}
      ln -s ${avante-nvim-lib}/lib/libavante_templates${ext} $out/build/avante_templates${ext}
      ln -s ${avante-nvim-lib}/lib/libavante_tokenizers${ext} $out/build/avante_tokenizers${ext}
    '';

    doInstallCheck = true;
  }
