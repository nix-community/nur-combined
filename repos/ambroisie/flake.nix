{
  description = "NixOS configuration with flakes";
  inputs = {
    agenix = {
      type = "github";
      owner = "ryantm";
      repo = "agenix";
      ref = "main";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    flake-parts = {
      type = "github";
      owner = "hercules-ci";
      repo = "flake-parts";
      ref = "main";
      inputs = {
        nixpkgs-lib.follows = "nixpkgs";
      };
    };

    futils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "main";
      inputs = {
        systems.follows = "systems";
      };
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    nur = {
      type = "github";
      owner = "nix-community";
      repo = "NUR";
      ref = "main";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    git-hooks = {
      type = "github";
      owner = "cachix";
      repo = "git-hooks.nix";
      ref = "master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    systems = {
      type = "github";
      owner = "nix-systems";
      repo = "default";
      ref = "main";
    };
  };

  # Can't eta-reduce a flake outputs...
  outputs = inputs: import ./flake inputs;
}
