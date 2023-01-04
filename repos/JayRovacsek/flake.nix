{
  description = "My NUR repository";
  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    stable.url = "github:nixos/nixpkgs/release-22.11";
    unstable = nixpkgs;

    # Adds flake compatability to start removing the vestiges of 
    # shell.nix and move us towards the more modern nix develop
    # setting while tricking some services/plugins to still be able to
    # use the shell.nix file.
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    vulnix-pre-commit = {
      url = "github:jayrovacsek/vulnix-pre-commit";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "flake-compat";
      };
    };

    # Adds configurable pre-commit options to our flake :)
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "flake-compat";
      };
    };
  };
  outputs = { self, flake-utils, ... }:
    let systems = import ./systems.nix;
    in flake-utils.lib.eachSystem [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
      "armv6l-linux"
      "armv7l-linux"
    ] (system:
      let
        # Note that the below use of pkgs will by implication mean that
        # our dev dependencies for local packages as well as part of our
        # devShell are pinned to stable - this is intended to ensure
        # backwards compatability & reduced pain when managing deps
        # in these spaces
        pkgs = self.inputs.nixpkgs.legacyPackages.${system};

        checks = {
          pre-commit-check = self.inputs.pre-commit-hooks.lib.${system}.run
            (import ./pre-commit-checks.nix { inherit self pkgs system; });
        };

        devShell = pkgs.mkShell {
          name = "nur-dev-shell";
          packages = with pkgs; [ nixfmt vulnix statix ];
          # Self reference to make the default shell hook that which generates
          # a suitable pre-commit hook installation
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };

        # Self reference the dev shell for our system to resolve the lacking
        # devShells.${system}.default recommended structure
        devShells.default = self.outputs.devShell.${system};

        lib = import ./lib { inherit pkgs; };

        packages = flake-utils.lib.flattenTree
          (import ./default.nix { inherit self pkgs system; });
      in { inherit lib devShell devShells packages checks; });
}
