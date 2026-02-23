{
  config,
  lib,
  pkgs,
  system,
  stablePkgs,
  ...
}:
let
  cfg = config.profiles;
in
{
  options = {
    profiles.dev.enable = lib.mkEnableOption "Development Programs to be available outside of a devshell";
    environment.pythonPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.python312.withPackages (
        ps:
        with ps;
        [
          distutils
          jupyter
          numpy
          pandas
          pip
          pipx
          pygraphviz
          python-dotenv
          setuptools
          virtualenv
        ]
        ++ config.environment.pythonPackages
      );
    };
    environment.pythonPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.dev.enable {
    virtualisation.podman.enable = true;
    environment = {
      systemPackages =
        with pkgs;
        [
          bison
          bruno
          bun
          cargo-generate
          cargo-make
          cargo-watch
          ccache
          cmake
          config.environment.pythonPackage
          dfu-util
          dioxus-cli
          dotnet-sdk
          flex
          gh
          gnumake
          gperf
          icu
          jujutsu
          libffi
          libiconv
          libusb1
          ninja
          nodejs
          nodePackages.prettier
          pipenv
          pkg-config
          rustup
          systemfd
          uv
          # esp-idf-full
        ]
        ++ lib.optionals cfg.gui.enable [
          jetbrains-toolbox
        ]
        ++ lib.optionals stdenv.isLinux [
          gcc
          clang
        ]
        ++
          lib.optionals
            (builtins.elem system [
              "aarch64-darwin"
              "aarch64-linux"
              "x86_64-linux"
            ])
            [
              deno
              neovide
            ];
    };
  };
}
