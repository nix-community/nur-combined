rec {
  description = "Nix flake template";

  inputs = {
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      _module.args = { inherit nixConfig; };
      systems = [ "x86_64-linux" ];
      imports = [
        ./treefmt.nix
        # optional: introduce nixpkgs into perSystem
        ./nixpkgs.nix
        ./pkgs/flake-module.nix
      ];
      perSystem =
        { pkgs, config, ... }:
        {
          devShells.default = pkgs.callPackage ./devshell.nix { };
          legacyPackages = {
            inherit (pkgs) nvfetcher;
            inherit (inputs) nixpkgs;
            ci = import ./ci.nix { nurAttrs = config.packages; };
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
      "https://numtide.cachix.org"
      "https://ccicnce113424.cachix.org"
      # "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "ccicnce113424.cachix.org-1:OWV4fSkx7o7TinVCSD98zPG8udShCIjhyaAdOIRNetw="
      # "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}
