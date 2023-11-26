{
  description = "Personal Nix Config: powered by flake-parts";

  nixConfig = {
    extra-substituters = [
      # default
      "https://cachix.cachix.org"
      "https://procyon.cachix.org"

      # from inputs
      "https://nix-community.cachix.org"
      "https://pre-commit-hooks.cachix.org"
    ];
    extra-trusted-public-keys = [
      # default
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "procyon.cachix.org-1:VljSnjtMCpriTsvji4EotHS9UZJoPMOCVk//fmmvIto="

      # from inputs
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
    ];
  };

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      # https://github.com/hercules-ci/flake-parts/pull/162#issuecomment-1570753296
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # nixpkgs
    nixpkgs-latest.url = "github:NixOS/nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-23.05";

    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flake modules
    flake-root.url = "github:srid/flake-root";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.gitignore.follows = "gitignore-nix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    flat-flake = {
      url = "github:linyinfeng/flat-flake";
      inputs.crane.follows = "crane";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-compat.follows = "flake-compat";
    };

    # libraries
    systems.url = "github:nix-systems/default";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    gitignore-nix = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # compatibility layer
    flake-compat = {
      flake = false;
      url = "github:edolstra/flake-compat";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ self, config, lib, ... }:
      let
        selfLib = import ./nix/lib { inherit self inputs config lib; };
      in
      {
        flake.lib = selfLib;

        imports = selfLib.buildModuleList ./nix/flake;

        systems = [ "x86_64-linux" ];
      });
}
