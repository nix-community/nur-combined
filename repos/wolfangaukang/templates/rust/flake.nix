{
  description = "A rust project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, devenv, ... }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (nixpkgs.lib.systems.flakeExposed);
      pkgsFor = forEachSystem (system: import nixpkgs { inherit system; });

    in {
      # packages = forEachSystem (system: {
      #   project = pkgsFor.${system}.callPackage ./package.nix { };
      #   default = self.outputs.packages.${system}.apep;
      # });
      # apps = forEachSystem (system: {
      #   default = { type = "app"; program = pkgsFor.${system}.lib.getExe self.outputs.packages.${system}.default; };
      # });
      formatter = forEachSystem (system: pkgsFor.${system}.nixpkgs-fmt);
      devShells = forEachSystem (system:
        let
          pkgs = pkgsFor.${system};
        in {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [ (import ./devenv.nix { inherit pkgs; lib = pkgs.lib; }) ];
          };
        });
      overlays.default = final: prev: { inherit (self.packages.${final.system}) apep; };
    };
}
