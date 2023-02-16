{
  description = "NixOS/Darwin configurations";

  inputs = {
    # Stable / Unstable split in packages
    stable.url = "github:nixos/nixpkgs/release-22.11";
    unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos-wsl = {
      url =
        "github:nix-community/NixOS-WSL/3721fe7c056e18c4ded6c405dbee719692a4528a";
      inputs = {
        nixpkgs.follows = "stable";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "flake-compat";
      };
    };

    # We need to wrap darwin as it exposes darwin.lib.darwinSystem
    # therefore we can't depend on stable/unstable to handle the correct matching
    # of stable/unstable to make a suitable decision per system
    darwin-stable = {
      inputs.nixpkgs.follows = "stable";
      url = "github:lnl7/nix-darwin/master";
    };
    darwin-unstable = {
      inputs.nixpkgs.follows = "unstable";
      url = "github:lnl7/nix-darwin/master";
    };

    # Adds flake compatability to start removing the vestiges of 
    # shell.nix and move us towards the more modern nix develop
    # setting while tricking some services/plugins to still be able to
    # use the shell.nix file.
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # Adds configurable pre-commit options to our flake :)
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "stable";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "flake-compat";
      };
    };

    # Secrets Management <3
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "stable";
    };

    # Terraform via the nix language
    terranix = {
      url = "github:terranix/terranix";
      inputs = {
        nixpkgs.follows = "stable";
        flake-utils.follows = "flake-utils";
      };
    };

    # Simply required for sane management of Firefox on darwin
    firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      inputs.nixpkgs.follows = "unstable";
    };

    # Home management module
    home-manager = {
      url = "github:rycee/home-manager/release-22.11";
      inputs.nixpkgs.follows = "stable";
    };

    # Microvm module, PoC state for implementation
    microvm = {
      url = "github:astro/microvm.nix";
      inputs = {
        nixpkgs.follows = "stable";
        flake-utils.follows = "flake-utils";
      };
    };

    # Generate system images easily
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "unstable";
    };

    # Apply opinions on hardware that are driven by community
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Like the Arch User Repository, but better :)
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, flake-utils, ... }:
    let
      # Systems we want to wrap all outputs below in. This is split into 
      # two segments; those items inside the flake-utils block and those not.
      # The flake-utils block will automatically generate the <system>
      # sub-properties for all exposed elements as per: https://nixos.wiki/wiki/Flakes#Output_schema
      exposedSystems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
    in flake-utils.lib.eachSystem exposedSystems (system: {
      # Space in which exposed derivations can be ran via
      # nix run .#foo - handy in the future for stuff like deploying
      # via terraform or automation tasks that are relatively 
      # procedural 
      apps = import ./apps { inherit self system; };

      # Pre-commit hooks to enforce formatting, lining, find 
      # antipatterns and ensure they don't reach upstream
      checks = import ./checks { inherit self system; };

      # Shell environments (applied to both nix develop and nix-shell via
      # shell.nix in top level directory)
      devShells = import ./shells { inherit self system; };

      # Formatter option for `nix fmt` - redundant via checks but nice to have
      formatter = self.inputs.unstable.legacyPackages.${system}.nixfmt;

      # Locally defined packages for flake consumption or consumption
      # on the nur via: pkgs.nur.repos.JayRovacsek if utilising the nur overlay
      # (all systems in this flake apply this opinion via the common.modules)
      # construct
      packages = import ./packages {
        inherit self system;
        pkgs = self.inputs.unstable.legacyPackages.${system};
      };
    }) // {
      inherit exposedSystems;

      # Useful functions to use throughout the flake
      lib = import ./lib { inherit self; };

      # Common/consistent values to be consumed by the flake
      common = import ./common { inherit self; };

      # Overlays for when stuff really doesn't fit in the round hole
      overlays = import ./overlays { inherit self; };

      # System configurations
      nixosConfigurations = import ./linux { inherit self; };
      darwinConfigurations = import ./darwin { inherit self; };
    };
}
