{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (_: {
      imports = [ inputs.treefmt-nix.flakeModule ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem =
        { pkgs, ... }:
        let
          legacyPackages = import ./default.nix { inherit pkgs; };
        in
        {
          inherit legacyPackages;
          packages = pkgs.lib.filterAttrs (_: v: pkgs.lib.isDerivation v) legacyPackages;

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
