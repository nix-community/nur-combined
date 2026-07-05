{
  description = "Packages from my personal dotfiles";

  inputs = {
    nixpkgs-patcher = {
      url = "github:dtomvan/nixpkgs-patcher";

      # disable all irrelevant inputs here since I only care about the
      # "resulting" nixpkgs-patched output
      inputs.nixpkgs.follows = "";
      inputs.systems.follows = "";
      inputs.flake-parts.follows = "";
      inputs.nix-patcher.follows = "";
    };
    nixpkgs.follows = "nixpkgs-patcher/nixpkgs-patched";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/devshell.nix
        ./modules/eval-check.nix
        ./modules/formatter.nix
        ./modules/koil-test.nix
        ./modules/nixos.nix
        ./modules/packages.nix
        ./modules/systems.nix
      ];
    };
}
