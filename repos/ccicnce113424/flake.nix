rec {
  description = "Nix flake template";

  inputs = {
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-compat.url = "github:lix-project/flake-compat";
    nvfetcher = {
      url = "github:berberman/nvfetcher/0.8.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crate2nix = {
      url = "github:nix-community/crate2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        nix-test-runner.follows = "";
        cachix.follows = "";
      };
    };
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      _module.args = { inherit nixConfig; };
      systems = [ "x86_64-linux" ];
      debug = true;
      imports = [
        ./treefmt.nix
        # optional: introduce nixpkgs into perSystem
        ./nixpkgs.nix
        ./pkgs/flake-module.nix
        ./modules/flake-module.nix
        ./tests/flake-module.nix
        ./github-actions.nix
      ];
      perSystem =
        { pkgs, inputs', ... }:
        let
          nvfetcher-bin = inputs'.nvfetcher.packages.default;
          crate2nix = inputs'.crate2nix.packages.default;
        in
        {
          devShells.default = pkgs.callPackage ./devshell.nix { inherit nvfetcher-bin; };
          packages = {
            inherit nvfetcher-bin crate2nix;
          };
          legacyPackages = {
            inherit nixpkgs;
            crate2nix-outpath = inputs.crate2nix;
          };
        };
    };

  nixConfig = {
    trusted-users = [ "@wheel" ];
    extra-experimental-features = [
      "nix-command"
      "flakes"
    ];
    accept-flake-config = true;
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://ccicnce113424.cachix.org"
      "https://eigenvalue.cachix.org"
      # "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ccicnce113424.cachix.org-1:OWV4fSkx7o7TinVCSD98zPG8udShCIjhyaAdOIRNetw="
      "eigenvalue.cachix.org-1:ykerQDDa55PGxU25CETy9wF6uVDpadGGXYrFNJA3TUs="
      # "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}
