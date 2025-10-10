{
  description = "lunik1's NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-lint = {
      url = "github:nix-community/nixpkgs-lint";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, ... }:
    with inputs;
    {
      nixosModules = import ./modules;
    }
    //
      flake-utils.lib.eachSystem
        [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "armv6l-linux" "armv7l-linux" ]
        (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ nixpkgs-lint.overlays.default ];
            };
          in
          {
            packages = import ./default.nix { inherit pkgs; };

            formatter = pkgs.nixfmt;

            devShells.default =
              with pkgs;
              mkShell {
                inherit (self.checks.${system}.pre-commit-check) shellHook;
                buildInputs = [
                  nix-output-monitor
                  nix-update
                  nixfmt
                  nixpkgs-lint
                  nurl
                  nil
                  statix
                ];
              };

            checks = {
              pre-commit-check = pre-commit-hooks.lib.${system}.run {
                src = ./.;
                hooks = {
                  nixfmt-rfc-style.enable = true;
                  statix.enable = true;
                };
              };
            };
          }
        );
}
