{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # flake-compat = {
    #   url = "github:edolstra/flake-compat";
    #   flake = false;
    # };
    flake-utils = {
      url = "git+https://github.com/numtide/flake-utils";
    };
    devenv = {
      inputs = {nixpkgs.follows = "nixpkgs";};
      url = "github:cachix/devenv";
    };
    treefmt-nix = {url = "github:numtide/treefmt-nix";};
  };
  outputs = { self, nixpkgs, flake-utils, treefmt-nix, devenv, ... }@inputs:
  flake-utils.lib.eachDefaultSystem (system:
    let

      pkgs = import nixpkgs { inherit system; };
      inherit (pkgs) lib;

      devshell = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          (import ./devenv.nix {
            inherit pkgs treefmt-nix;
          })
        ];
      };

      example-package = pkgs.callPackage ./pkgs/example-package/default.nix {};
      hello-nur = pkgs.callPackage ./pkgs/hello-nur/default.nix {};
      lsd-git = pkgs.callPackage ./pkgs/lsd-git/default.nix {};
      rusty-rain = pkgs.callPackage ./pkgs/rusty-rain/default.nix {};
      shinydir = pkgs.callPackage ./pkgs/shinydir/default.nix {};
      specsheet = pkgs.callPackage ./pkgs/specsheet/default.nix {};
 
    in
    {
      devShells.default = devshell;

      packages = {
        default = example-package;
        example-package = example-package;
        hello-nur = hello-nur;
        lsd-git = lsd-git;
        rusty-rain = rusty-rain;
        shinydir = shinydir;
        specsheet = specsheet;
      };

      # legacyPackages = forAllSystems (system: import ./default.nix {
      #   pkgs = import nixpkgs { inherit system; };
      # });
      # packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
    });
}
