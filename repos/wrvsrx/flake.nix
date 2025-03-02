{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:wrvsrx/nixpkgs/patched-nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, inputs, ... }:
      let
        overlay = import ./pkgs/overlay.nix;
      in
      {
        systems = [ "x86_64-linux" ];
        flake = {
          templates = import ./templates;
          overlays.default = overlay;
          nixosModules.default = ./nixos/modules;
        };
        perSystem =
          { pkgs, system, ... }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
            packages = inputs.flake-utils.lib.flattenTree (import ./. { inherit pkgs; });
            formatter = pkgs.nixfmt-rfc-style;
            devShells.default = pkgs.mkShell {
              nativeBuildInputs = with pkgs; [
                nvfetcher
                nix-update

                treefmt
                taplo
              ];
            };
          };
      }
    );
}
