{
  description = "Template for Rust projects";

  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, devshell, nixpkgs, ... }:
    let
      inherit (nixpkgs.lib) genAttrs;
      systems = nixpkgs.lib.systems.flakeExposed;
      forEachSystem = genAttrs systems;
      pkgsFor = forEachSystem (system: import nixpkgs {
        inherit system;
        overlays = [ devshell.overlays.default ];
      });

    in
    {
      devShells = forEachSystem (system:
        let
          inherit (pkgsFor.${system}.devshell) mkShell importTOML;
        in
        {
          default = mkShell { imports = [ (importTOML ./devshell.toml) ]; };
        });
    };
}
