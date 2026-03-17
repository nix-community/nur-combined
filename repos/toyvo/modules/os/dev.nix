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
          pnpm
          gemini-cli-bin
          claude-code-bin
          codex
          opencode
          nodePackages.prettier
          pipenv
          pkg-config
          pnpm
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
