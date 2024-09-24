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
  version = "2024-09-23";

  src = fetchFromGitHub {
    owner = "yetone";
    repo = "avante.nvim";
    rev = "5aec0ba48bb0342c116662aafb6fe58c1cf9d44a";
    hash = "sha256-FeFCzp4NkFwGspsNLSPkQ1Ti5aMoUtsCKjhId/EN2eA=";
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
      outputHashes = {
        "mlua-0.10.0-beta.1" = "sha256-ZEZFATVldwj0pmlmi0s5VT0eABA15qKhgjmganrhGBY=";
      };
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
  };
in
  buildVimPlugin {
    pname = "avante.nvim";
    inherit version src meta;

    postInstall = let
      ext = stdenv.hostPlatform.extensions.sharedLibrary;
    in ''
      mkdir -p $out/build
      ln -s ${avante-nvim-lib}/lib/libavante_templates${ext} $out/build/avante_templates${ext}
      ln -s ${avante-nvim-lib}/lib/libavante_tokenizers${ext} $out/build/avante_tokenizers${ext}
    '';

    doInstallCheck = true;
  }
