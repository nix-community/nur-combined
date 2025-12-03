{
  description = "A Golang project";

  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    nixpkgs.url = "github:nixos/nixpkgs";
    devenv = {
      url = "github:cachix/devenv";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
    gorin = {
      url = "git+https://codeberg.org/wolfangaukang/gorin";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        devenv.follows = "devenv";
        flake-compat.follows = "flake-compat";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      devenv,
      ...
    }@inputs:
    let

      forEachSystem = nixpkgs.lib.genAttrs (nixpkgs.lib.systems.flakeExposed);
      pkgsFor = forEachSystem (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ inputs.gorin.overlays.default ];
        }
      );

    in
    {
      formatter = forEachSystem (system: pkgsFor.${system}.nixpkgs-fmt);
      devShells = forEachSystem (
        system:
        let
          pkgs = pkgsFor.${system};
        in
        {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              (import ./devenv.nix {
                inherit pkgs;
                lib = pkgs.lib;
              })
            ];
          };
        }
      );
      # Uncomment this after being able to write a working package.nix
      # packages = forEachSystem (system: {
      #   project = pkgsFor.${system}.callPackage ./package.nix { };
      #   default = self.outputs.packages.${system}.project;
      # });
      # apps = forEachSystem (system: {
      #   default = { type = "app"; program = pkgsFor.${system}.lib.getExe self.outputs.packages.${system}.default; };
      # });
      # overlays.default = final: prev: { inherit (self.packages.${final.system}) project; };
    };
}
