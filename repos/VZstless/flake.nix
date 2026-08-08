{
  description = "Nix User Repo from Victrix (VZstless).";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      lib = nixpkgs.lib;
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      apps = forAllSystems (system: {
        update = let
          pkgs = import nixpkgs { inherit system; };
        in {
          type = "app";
          program = toString (pkgs.writeShellScript "nur-update" ''
            exec ${pkgs.nix}/bin/nix-shell ${./update.nix} --argstr nixpkgsPath ${nixpkgs.outPath} --argstr nurPath ${self.outPath} "$@"
          '');
        };
      });
    };
}
