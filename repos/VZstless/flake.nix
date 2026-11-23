{
  description = "Nix User Repo from VZstless.";
  nixConfig = {
    extra-substituters = [
      "https://vzstless-nur.cachix.org"
    ];
    extra-trusted-public-keys = [
      "vzstless-nur.cachix.org-1:m9PoVZ5iQyNlsT2UHUD20nr0EJ2z1qiA9DhOTDWu3sA="
    ];
  };
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
            exec ${pkgs.nix}/bin/nix-shell ${./update.nix} --argstr nixpkgsPath ${nixpkgs.outPath} --argstr nurPath "$PWD" "$@"
          '');
        };
      });
    };
}
