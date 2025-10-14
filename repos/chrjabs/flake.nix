{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (_: {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.treefmt-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        {
          pkgs,
          config,
          ...
        }:
        let
          legacyPackages =
            builtins.removeAttrs
              (import ./default.nix {
                inherit pkgs;
                inherit (inputs) rust-overlay;
              })
              [
                "lib"
                "overlays"
                "modules"
              ];
        in
        {
          inherit legacyPackages;
          packages = pkgs.lib.filterAttrs (_: v: pkgs.lib.isDerivation v) legacyPackages;

          # Default overlay, making all packages available
          # For some reason this doesn't work by setting `overlayAttrs = config.packages`
          overlayAttrs = {
            inherit (config.packages)
              dblp-tools
              gbd
              gbdc
              gbdc-tool
              kani
              python-mip
              veripb
              gimsatul
              coveralls
              cargo-afl
              janus-swi
              pyclingo
              ;
          };

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [ cachix ];
            shellHook = ''
              export CACHIX_AUTH_TOKEN=$(pass cachix-token)
            '';
          };

          treefmt = {
            settings.global.on-unmatched = "error";
            programs = {
              # Spellchecking
              typos.enable = true;
              # Nix
              deadnix.enable = true;
              nixfmt.enable = true;
              # Shell
              shellcheck = {
                enable = true;
                excludes = [ ".envrc" ];
              };
              shfmt.enable = true;
              # TOML
              taplo.enable = true;
              # Github actions
              actionlint.enable = true;
              yamlfmt.enable = true;
            };
          };
        };
    });
}
