{
  description = "Ray's personal NUR repository";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      repositoryFor =
        system:
        import ./default.nix {
          pkgs = pkgsFor system;
        };
    in
    {
      overlays = import ./overlays;
      homeModules = import ./home-modules;

      legacyPackages = forAllSystems repositoryFor;

      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isDerivation) (repositoryFor system)
      );

      apps = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          updatePackages = pkgs.callPackage ./tools/update-packages { } self.packages.${system};
        in
        {
          update = {
            type = "app";
            program = "${updatePackages}/bin/update-packages";
            meta.description = "Update every package with an update script";
          };
        }
      );

      formatter = forAllSystems (system: (pkgsFor system).nixfmt-tree);

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              actionlint
              deno
              nixfmt-tree
            ];
          };
        }
      );
    };
}
