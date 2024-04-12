{
  description = "Template for Go projects";

  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { devshell, nixpkgs, ... }:
    let
      systems = nixpkgs.lib.systems.flakeExposed;
      forEachSystem = nixpkgs.lib.genAttrs systems;
      pkgsFor = forEachSystem (system: import nixpkgs {
        inherit system;
        overlays = [ devshell.overlays.default ];
      });
    in
    {
      packages = forEachSystem (system: {
        default = pkgsFor.${system}.callPackage ./package.nix { };
      });
      devShells = forEachSystem (system:
        let
          inherit (pkgsFor.${system}.devshell) mkShell importTOML;
        in
        {
          default = mkShell { imports = [ (importTOML ./devshell.toml) ]; };
        });
      formatter = forEachSystem (system: pkgsFor.${system}.nixpkgs-fmt);
    };
}
