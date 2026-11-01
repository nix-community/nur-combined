{
  description = "NUR packages of @nagy";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    # One nixpkgs closure, no duplicates.
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      system = "x86_64-linux";
      # allowBroken: some packages here track rolling nixpkgs and depend on
      # upstream packages that nixpkgs currently marks broken.
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowBroken = true;
          allowUnfree = true;
        };
      };
      lib = pkgs.lib;
    in
    {
      # NUR convention: the full attribute set that default.nix returns.
      # It carries lib, modules, python3Packages, emacsPackages and the
      # package sets that are not plain derivations.
      legacyPackages.${system} = import ./. { inherit pkgs; };

      # The flake schema wants derivations only. Discover the packages with
      # the same trick that default.nix uses, so no package name is listed.
      packages.${system} = lib.packagesFromDirectoryRecursive {
        directory = ./pkgs/by-name;
        callPackage = pkgs.callPackage;
      };

      formatter.${system} = treefmt-nix.lib.mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };
    };
}
